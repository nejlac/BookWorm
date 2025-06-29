using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Services.DataBase;
using Microsoft.EntityFrameworkCore;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BookWorm.Model.Exceptions;

namespace BookWorm.Services.BookStateMachine
{
    public class BaseBookState
    {
        protected readonly IServiceProvider _serviceProvider;
        protected readonly BookWormDbContext _context;
        protected readonly IMapper _mapper;

        public BaseBookState(IServiceProvider serviceProvider, BookWormDbContext context, IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<BookResponse> CreateAsync(BookCreateUpdateRequest request)
        {
            throw new BookException("Not allowed");
        }

        public virtual async Task<BookResponse> UpdateAsync(int id, BookCreateUpdateRequest request)
        {
            throw new BookException("Not allowed");
        }
        
        public virtual async Task<BookResponse> AcceptAsync(int id)
        {
            throw new BookException("Not allowed")
            {

            };
        }

        public virtual async Task<BookResponse> DeclineAsync(int id)
        {
            throw new BookException("Not allowed");
        }

        public BaseBookState GetBookState(string stateName) 
        {
            switch (stateName)
            {
                case "Submitted":
                    return _serviceProvider.GetService<SubmittedBookState>();
                case "Accepted":
                    return _serviceProvider.GetService<AcceptedBookState>();
                case "Declined":
                    return _serviceProvider.GetService<DeclinedBookState>();   

                default:
                    throw new Exception($"State {stateName} not defined");
            }
        }

        protected async Task HandleGenreRelationships(int bookId, List<int> genreIds)
        {
            var existingBookGenres = await _context.BookGenres.Where(bg => bg.BookId == bookId).ToListAsync();
            _context.BookGenres.RemoveRange(existingBookGenres);

            if (genreIds != null && genreIds.Count > 0)
            {
                foreach (var genreId in genreIds)
                {
                    if (await _context.Genres.AnyAsync(g => g.Id == genreId))
                    {
                        var bookGenre = new BookGenre { BookId = bookId, GenreId = genreId };
                        _context.BookGenres.Add(bookGenre);
                    }
                }
            }

            await _context.SaveChangesAsync();
        }

        protected BookResponse MapToResponse(Book book)
        {
            return new BookResponse
            {
                Id = book.Id,
                Title = book.Title,
                AuthorId = book.AuthorId,
                AuthorName = book.Author?.Name ?? string.Empty,
                Description = book.Description,
                PublicationYear = book.PublicationYear,
                PageCount = book.PageCount,
                CoverImageUrl = book.CoverImageUrl,
                CreatedAt = book.CreatedAt,
                UpdatedAt = book.UpdatedAt,
                BookState = book.BookState,
                CreatedByUserId = book.CreatedByUserId,
                CreatedByUserName = book.CreatedByUser?.Username ?? string.Empty,
                Genres = book.BookGenres?.Select(bg => bg.Genre.Name).ToList() ?? new List<string>()
            };
        }
    }
}
