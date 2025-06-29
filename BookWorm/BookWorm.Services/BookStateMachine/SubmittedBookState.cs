using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.Exceptions;
using BookWorm.Services.DataBase;
using Microsoft.EntityFrameworkCore;
using MapsterMapper;
using System;
using System.Threading.Tasks;

namespace BookWorm.Services.BookStateMachine
{
    public class SubmittedBookState : BaseBookState
    {
        public SubmittedBookState(IServiceProvider serviceProvider, BookWormDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }

        public override async Task<BookResponse> CreateAsync(BookCreateUpdateRequest request)
        {
            // Validation
            if (await _context.Books.AnyAsync(b => b.Title == request.Title && b.AuthorId == request.AuthorId))
            {
                throw new BookException("A book with this title and author already exists.");
            }

            if (request.GenreIds == null || request.GenreIds.Count == 0)
            {
                throw new BookException("At least one genre must be selected for the book.");
            }

            var book = new Book();
            _mapper.Map(request, book);

            book.BookState = "Submitted";
            book.CreatedByUserId = request.CreatedByUserId;
            book.CreatedAt = DateTime.Now;
            book.UpdatedAt = DateTime.Now;

            _context.Books.Add(book);
            await _context.SaveChangesAsync();

            await HandleGenreRelationships(book.Id, request.GenreIds);

            var bookWithRelations = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.BookGenres)
                .ThenInclude(bg => bg.Genre)
                .Include(b => b.CreatedByUser)
                .FirstOrDefaultAsync(b => b.Id == book.Id);

            return MapToResponse(bookWithRelations!);
        }
        
        public override async Task<BookResponse> AcceptAsync(int id)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                throw new BookException("Book not found");

            book.BookState = "Accepted";
            book.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            var bookWithRelations = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.BookGenres)
                .ThenInclude(bg => bg.Genre)
                .Include(b => b.CreatedByUser)
                .FirstOrDefaultAsync(b => b.Id == id);

            return MapToResponse(bookWithRelations!);
        }
        
        public override async Task<BookResponse> DeclineAsync(int id)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                throw new BookException("Book not found");

            book.BookState = "Declined";
            book.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            var bookWithRelations = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.BookGenres)
                .ThenInclude(bg => bg.Genre)
                .Include(b => b.CreatedByUser)
                .FirstOrDefaultAsync(b => b.Id == id);

            return MapToResponse(bookWithRelations!);
        }
    }
}
