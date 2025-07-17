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

        public BookReviewService(BookWormDbContext context, IMapper mapper, ILogger<BookReviewService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
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