using BookWorm.Model.Exceptions;
using BookWorm.Model.Messages;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Services.DataBase;
using EasyNetQ;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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

        public override async Task<BookResponse> UpdateAsync(int id, BookCreateUpdateRequest request)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                throw new BookException("Book not found");

            if (await _context.Books.AnyAsync(b => b.Title == request.Title && b.AuthorId == request.AuthorId && b.Id != id))
            {
                throw new BookException("A book with this title and author already exists.");
            }

            if (request.GenreIds == null || request.GenreIds.Count == 0)
            {
                throw new BookException("At least one genre must be selected for the book.");
            }

            // Preserve the original created by user ID
            var originalCreatedByUserId = book.CreatedByUserId;

            _mapper.Map(request, book);
            
            // Restore the original created by user ID
            book.CreatedByUserId = originalCreatedByUserId;
            book.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();

            await HandleGenreRelationships(id, request.GenreIds);

            var bookWithRelations = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.BookGenres)
                .ThenInclude(bg => bg.Genre)
                .Include(b => b.CreatedByUser)
                .FirstOrDefaultAsync(b => b.Id == id);

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

            // Publish to RabbitMQ using environment variables
            try
            {
                var rabbitMqHost = Environment.GetEnvironmentVariable("RabbitMQ:HostName") ?? "localhost";
                var rabbitMqUsername = Environment.GetEnvironmentVariable("RabbitMQ:Username") ?? "guest";
                var rabbitMqPassword = Environment.GetEnvironmentVariable("RabbitMQ:Password") ?? "guest";
                
                Console.WriteLine($"Connecting to RabbitMQ at: {rabbitMqHost} with user: {rabbitMqUsername}");
                
                var connectionString = $"host={rabbitMqHost};username={rabbitMqUsername};password={rabbitMqPassword};timeout=10";
                var bus = RabbitHutch.CreateBus(connectionString);

                var accepted = new BookAccepted
                {
                    Book = MapToResponse(bookWithRelations!)
                };

                await bus.PubSub.PublishAsync(accepted);
                Console.WriteLine($"Successfully published BookAccepted message for book: {book.Title}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error publishing to RabbitMQ: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
                // Don't throw the exception to avoid breaking the book acceptance flow
                // The book is already accepted in the database
            }

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
