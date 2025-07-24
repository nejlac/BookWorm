using BookWorm.Model.Exceptions;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class BookReviewService : BaseCRUDService<BookReviewResponse, BookReviewSearchObject, BookReview, BookReviewCreateUpdateRequest, BookReviewCreateUpdateRequest>, IBookReviewService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<BookReviewService> _logger;
        private readonly IReadingListService _readingListService;

        public BookReviewService(BookWormDbContext context, IMapper mapper, ILogger<BookReviewService> logger, IReadingListService readingListService) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _readingListService = readingListService;
        }

        protected override IQueryable<BookReview> ApplyFilter(IQueryable<BookReview> query, BookReviewSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(br => br.User.Username.Contains(search.Username));
            }
            if (!string.IsNullOrEmpty(search.BookTitle))
            {
                query = query.Where(br => br.Book.Title.Contains(search.BookTitle));
            }
            if (search.Rating.HasValue)
                query = query.Where(br => br.Rating == search.Rating);
            if (search.IsChecked.HasValue)
                query = query.Where(br => br.isChecked == search.IsChecked);

           
            query = query.Include(br => br.User).Include(br => br.Book);
            return query;
        }

        protected override BookReviewResponse MapToResponse(BookReview entity)
        {
            return new BookReviewResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                UserName = entity.User?.Username ?? string.Empty,
                BookId = entity.BookId,
                BookTitle = entity.Book?.Title ?? string.Empty,
                Review = entity.Review ?? string.Empty,
                Rating = entity.Rating,
                IsChecked = entity.isChecked,
                CreatedAt = entity.CreatedAt
            };
        }

        protected override async Task BeforeInsert(BookReview entity, BookReviewCreateUpdateRequest request)
        {
            if (await _context.BookReviews.AnyAsync(br => 
                br.UserId == request.UserId && 
                br.BookId == request.BookId))
            {
                throw new BookReviewException($"User has already reviewed this book. Only one review per user per book is allowed.");
            }

           
            if (request.Rating < 1 || request.Rating > 5)
            {
                throw new BookReviewException("Rating must be between 1 and 5.");
            }

           
            entity.CreatedAt = DateTime.Now;
            entity.isChecked = false;

            _logger.LogInformation($"[BookReviewService] _readingListService is null: {_readingListService == null}");
            try {
                var readList = (await _readingListService.GetAsync(new ReadingListSearchObject { UserId = request.UserId, Name = "Read" })).FirstOrDefault();
                if (readList == null)
                {
                   
                    var createReq = new ReadingListCreateUpdateRequest
                    {
                        UserId = request.UserId,
                        Name = "Read",
                        Description = "Books I have read",
                        IsPublic = true,
                        BookIds = new List<int> { request.BookId }
                    };
                    await _readingListService.CreateAsync(createReq);
                }
                else if (!readList.Books.Any(b => b.BookId == request.BookId))
                {
                    _logger.LogInformation($"[BookReviewService] Adding book {request.BookId} to existing 'Read' list {readList.Id} for user {request.UserId}");
                    await _readingListService.AddBookToListAsync(readList.Id, request.BookId, DateTime.Now);
                }
                else
                {
                    _logger.LogInformation($"[BookReviewService] Book {request.BookId} already in 'Read' list for user {request.UserId}");
                }
            } catch (Exception ex) {
                _logger.LogError(ex, $"[BookReviewService] Error adding book to Read list: {ex.Message}");
            }
        }

        protected override async Task BeforeUpdate(BookReview entity, BookReviewCreateUpdateRequest request)
        {
            
            if (request.Rating < 1 || request.Rating > 5)
            {
                throw new BookReviewException("Rating must be between 1 and 5.");
            }
        }

        public override async Task<BookReviewResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.BookReviews
                .Include(br => br.User)
                .Include(br => br.Book)
                .FirstOrDefaultAsync(br => br.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }
    }
} 