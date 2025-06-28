using BookWorm.Model.Exceptions;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class BookService : IBookService
    {
        private readonly BookWormDbContext _context;

        public BookService(BookWormDbContext context)
        {
            _context = context;
        }

        public async Task<List<BookResponse>> GetAsync(BookSearchObject search)
        {
            var query = _context.Books.Include(b => b.Author).Include(b => b.BookGenres).ThenInclude(bg => bg.Genre).AsQueryable();

            if (!string.IsNullOrEmpty(search.Title))
                query = query.Where(b => b.Title.Contains(search.Title));
            if (!string.IsNullOrEmpty(search.Author))
                query = query.Where(b => b.Author.Name.Contains(search.Author));
            if (search.GenreId.HasValue)
                query = query.Where(b => b.BookGenres.Any(bg => bg.GenreId == search.GenreId));
            if (search.PublicationYear.HasValue)
                query = query.Where(b => b.PublicationYear == search.PublicationYear);
            if (search.RPageCount.HasValue)
                query = query.Where(b => b.PageCount == search.RPageCount);

            var books = await query.ToListAsync();
            return books.Select(MapToResponse).ToList();
        }

        public async Task<BookResponse?> GetByIdAsync(int id)
        {
            var book = await _context.Books.Include(b => b.Author).Include(b => b.BookGenres).ThenInclude(bg => bg.Genre).FirstOrDefaultAsync(b => b.Id == id);
            return book != null ? MapToResponse(book) : null;
        }

        public async Task<BookResponse> CreateAsync(BookCreateUpdateRequest request)
        {
            if (await _context.Books.AnyAsync(b => b.Title == request.Title && b.AuthorId == request.AuthorId))
            {
                throw new BookException("A book with this title and author already exists.");
            }

            
            if (request.GenreIds == null || request.GenreIds.Count == 0)
            {
                throw new BookException("At least one genre must be selected for the book.");
            }

            var book = new Book
            {
                Title = request.Title,
                AuthorId = request.AuthorId,
                Description = request.Description,
                PublicationYear = request.PublicationYear,
                PageCount = request.PageCount,
                CoverImageUrl = request.CoverImageUrl ?? new byte[0],
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };
            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            if (request.GenreIds != null && request.GenreIds.Count > 0)
            {
                foreach (var genreId in request.GenreIds)
                {
                    if (await _context.Genres.AnyAsync(g => g.Id == genreId))
                    {
                        var bookGenre = new BookGenre { BookId = book.Id, GenreId = genreId };
                        _context.BookGenres.Add(bookGenre);
                    }
                }
                await _context.SaveChangesAsync();
            }
            return await GetBookResponseWithGenresAsync(book.Id);
        }

        public async Task<BookResponse?> UpdateAsync(int id, BookCreateUpdateRequest request)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                return null;
            if (await _context.Books.AnyAsync(b => b.Title == request.Title && b.AuthorId == request.AuthorId && b.Id != id))
            {
                throw new BookException("A book with this title and author already exists.");
            }

            
            if (request.GenreIds == null || request.GenreIds.Count == 0)
            {
                throw new BookException("At least one genre must be selected for the book.");
            }

            book.Title = request.Title;
            book.AuthorId = request.AuthorId;
            book.Description = request.Description;
            book.PublicationYear = request.PublicationYear;
            book.PageCount = request.PageCount;
            book.CoverImageUrl = request.CoverImageUrl ?? book.CoverImageUrl;
            book.UpdatedAt = DateTime.Now;

            var existingBookGenres = await _context.BookGenres.Where(bg => bg.BookId == id).ToListAsync();
            _context.BookGenres.RemoveRange(existingBookGenres);
            if (request.GenreIds != null && request.GenreIds.Count > 0)
            {
                foreach (var genreId in request.GenreIds)
                {
                    if (await _context.Genres.AnyAsync(g => g.Id == genreId))
                    {
                        var bookGenre = new BookGenre { BookId = book.Id, GenreId = genreId };
                        _context.BookGenres.Add(bookGenre);
                    }
                }
            }
            await _context.SaveChangesAsync();
            return await GetBookResponseWithGenresAsync(book.Id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                return false;
            _context.Books.Remove(book);
            await _context.SaveChangesAsync();
            return true;
        }

        private BookResponse MapToResponse(Book book)
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
                Genres = book.BookGenres.Select(bg => bg.Genre.Name).ToList()
            };
        }

        private async Task<BookResponse> GetBookResponseWithGenresAsync(int bookId)
        {
            var book = await _context.Books.Include(b => b.Author).Include(b => b.BookGenres).ThenInclude(bg => bg.Genre).FirstOrDefaultAsync(b => b.Id == bookId);
            if (book == null)
                throw new BookException("Book not found");
            return MapToResponse(book);
        }
    }
} 