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
    public class ReadingListService : IReadingListService
    {
        private readonly BookWormDbContext _context;
        private readonly IReadingChallengeService _readingChallengeService;

        public ReadingListService(BookWormDbContext context, IReadingChallengeService readingChallengeService)
        {
            _context = context;
            _readingChallengeService = readingChallengeService;
        }

        public async Task<List<ReadingListResponse>> GetAsync(ReadingListSearchObject search)
        {
            var query = _context.ReadingLists.Include(rl => rl.User).Include(rl => rl.ReadingListBooks).ThenInclude(rlb => rlb.Book).AsQueryable();
            if (search.UserId.HasValue)
                query = query.Where(rl => rl.UserId == search.UserId);
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(rl => rl.Name.ToLower() == search.Name.ToLower());
            if (search.IsPublic.HasValue)
                query = query.Where(rl => rl.IsPublic == search.IsPublic);
            var lists = await query.ToListAsync();
            return lists.Select(MapToResponse).ToList();
        }

        public async Task<ReadingListResponse?> GetByIdAsync(int id)
        {
            var list = await _context.ReadingLists.Include(rl => rl.User).Include(rl => rl.ReadingListBooks).ThenInclude(rlb => rlb.Book).FirstOrDefaultAsync(rl => rl.Id == id);
            return list != null ? MapToResponse(list) : null;
        }

        public async Task<ReadingListResponse> CreateAsync(ReadingListCreateUpdateRequest request)
        {
            // Validate that the name is not a default list name (only for user-created lists)
            var defaultNames = new[] { "Want to read", "Currently reading", "Read" };
            if (!request.IsSystemCreated && defaultNames.Any(defaultName => 
                string.Equals(defaultName, request.Name, StringComparison.OrdinalIgnoreCase)))
            {
                throw new ReadingListException("This name is reserved for default lists. Please choose a different name.");
            }

            var list = new ReadingList
            {
                UserId = request.UserId,
                Name = request.Name,
                Description = request.Description,
                IsPublic = request.IsPublic,
                CreatedAt = DateTime.Now
            };
            _context.ReadingLists.Add(list);
            await _context.SaveChangesAsync();
            if (request.BookIds != null && request.BookIds.Count > 0)
            {
                foreach (var bookId in request.BookIds)
                {
                    if (await _context.Books.AnyAsync(b => b.Id == bookId))
                    {
                        DateTime? readAt = null;
                        if (request.BookReadDates != null && request.BookReadDates.TryGetValue(bookId, out var date) && date.HasValue)
                            readAt = date.Value;
                        else
                            readAt = DateTime.Now;
                        var rlb = new ReadingListBook { ReadingListId = list.Id, BookId = bookId, AddedAt = DateTime.Now, ReadAt = readAt };
                        _context.ReadingListBooks.Add(rlb);
                        
                        // Update challenge progress if book was read AND it's being added to a "Read" list
                        if (readAt.HasValue && request.Name.ToLower() == "read")
                        {
                            var year = readAt.Value.Year;
                            await _readingChallengeService.AddBookToChallengeAsync(request.UserId, year, bookId, readAt.Value);
                        }
                    }
                }
                await _context.SaveChangesAsync();
            }
            return await GetReadingListResponseWithBooksAsync(list.Id);
        }

        public async Task<ReadingListResponse?> UpdateAsync(int id, ReadingListCreateUpdateRequest request)
        {
            var list = await _context.ReadingLists.FindAsync(id);
            if (list == null)
                return null;
                
            // Validate that the name is not a default list name (only for user-created lists)
            var defaultNames = new[] { "Want to read", "Currently reading", "Read" };
            if (!request.IsSystemCreated && defaultNames.Any(defaultName => 
                string.Equals(defaultName, request.Name, StringComparison.OrdinalIgnoreCase)))
            {
                throw new ReadingListException("This name is reserved for default lists. Please choose a different name.");
            }
            
            list.Name = request.Name;
            list.Description = request.Description;
            list.IsPublic = request.IsPublic;
            var existingBooks = await _context.ReadingListBooks.Where(rlb => rlb.ReadingListId == id).ToListAsync();
            _context.ReadingListBooks.RemoveRange(existingBooks);
            if (request.BookIds != null && request.BookIds.Count > 0)
            {
                foreach (var bookId in request.BookIds)
                {
                    if (await _context.Books.AnyAsync(b => b.Id == bookId))
                    {
                        DateTime? readAt = null;
                        if (request.BookReadDates != null && request.BookReadDates.TryGetValue(bookId, out var date) && date.HasValue)
                            readAt = date.Value;
                        else
                            readAt = DateTime.Now;
                        var rlb = new ReadingListBook { ReadingListId = list.Id, BookId = bookId, AddedAt = DateTime.Now, ReadAt = readAt };
                        _context.ReadingListBooks.Add(rlb);
                        
                        // Update challenge progress if book was read AND it's being added to a "Read" list
                        if (readAt.HasValue && request.Name.ToLower() == "read")
                        {
                            var year = readAt.Value.Year;
                            await _readingChallengeService.AddBookToChallengeAsync(list.UserId, year, bookId, readAt.Value);
                        }
                    }
                }
            }
            await _context.SaveChangesAsync();
            return await GetReadingListResponseWithBooksAsync(list.Id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var list = await _context.ReadingLists.FindAsync(id);
            if (list == null)
                return false;
            _context.ReadingLists.Remove(list);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<ReadingListResponse> AddBookToListAsync(int readingListId, int bookId, DateTime? readAt = null)
        {
            var list = await _context.ReadingLists.Include(rl => rl.ReadingListBooks).FirstOrDefaultAsync(rl => rl.Id == readingListId);
            if (list == null)
                throw new ReadingListException("Reading list not found");
            if (!await _context.Books.AnyAsync(b => b.Id == bookId))
                throw new ReadingListException("Book not found");
            if (list.ReadingListBooks.Any(rlb => rlb.BookId == bookId))
                throw new ReadingListException("Book already in the list");
            var actualReadAt = readAt ?? DateTime.Now;
            var rlb = new ReadingListBook
            {
                ReadingListId = readingListId,
                BookId = bookId,
                AddedAt = DateTime.Now,
                ReadAt = actualReadAt
            };
            _context.ReadingListBooks.Add(rlb);
            await _context.SaveChangesAsync();

           
            // Update challenge progress if book was read AND it's being added to a "Read" list
            if (actualReadAt != null && list.Name.ToLower() == "read")
            {
                var year = actualReadAt.Year;
                await _readingChallengeService.AddBookToChallengeAsync(list.UserId, year, bookId, actualReadAt);
            }

            return await GetReadingListResponseWithBooksAsync(readingListId);
        }

        public async Task<ReadingListResponse> RemoveBookFromListAsync(int readingListId, int bookId)
        {
            var list = await _context.ReadingLists.Include(rl => rl.ReadingListBooks).FirstOrDefaultAsync(rl => rl.Id == readingListId);
            if (list == null)
                throw new ReadingListException("Reading list not found");
            
            var bookInList = list.ReadingListBooks.FirstOrDefault(rlb => rlb.BookId == bookId);
            if (bookInList == null)
                throw new ReadingListException("Book not found in the list");
            
            // Store the read date and user ID before removing the book
            var readAt = bookInList.ReadAt;
            var userId = list.UserId;
            
            _context.ReadingListBooks.Remove(bookInList);
            await _context.SaveChangesAsync();

            // If the book was read AND it was from a "Read" list, update challenge progress for that year
            if (readAt.HasValue && list.Name.ToLower() == "read")
            {
                var year = readAt.Value.Year;
                await _readingChallengeService.RemoveBookFromChallengeAsync(userId, year, bookId);
            }

            return await GetReadingListResponseWithBooksAsync(readingListId);
        }

        private ReadingListResponse MapToResponse(ReadingList list)
        {
            var response = new ReadingListResponse
            {
                Id = list.Id,
                UserId = list.UserId,
                UserName = list.User?.Username ?? string.Empty,
                Name = list.Name,
                Description = list.Description,
                IsPublic = list.IsPublic,
                CreatedAt = list.CreatedAt,
                CoverImagePath = list.CoverImagePath,
                Books = list.ReadingListBooks.Select(rlb => new ReadingListBookResponse
                {
                    BookId = rlb.BookId,
                    Title = rlb.Book?.Title ?? string.Empty,
                    AddedAt = rlb.AddedAt,
                    CoverImagePath = rlb.Book?.CoverImagePath
                }).ToList()
            };

         
            Console.WriteLine($"=== DEBUG: Mapping ReadingList '{list.Name}' ===");
            Console.WriteLine($"  - CoverImagePath: {list.CoverImagePath}");
            Console.WriteLine($"  - Books count: {list.ReadingListBooks.Count}");
            foreach (var book in list.ReadingListBooks)
            {
                Console.WriteLine($"    Book: {book.Book?.Title} (ID: {book.BookId})");
                Console.WriteLine($"      - Book CoverImagePath: {book.Book?.CoverImagePath}");
            }
            Console.WriteLine("---");

            return response;
        }

        private async Task<ReadingListResponse> GetReadingListResponseWithBooksAsync(int listId)
        {
            var list = await _context.ReadingLists.Include(rl => rl.User).Include(rl => rl.ReadingListBooks).ThenInclude(rlb => rlb.Book).FirstOrDefaultAsync(rl => rl.Id == listId);
            if (list == null)
                throw new ReadingListException("ReadingList not found");
            return MapToResponse(list);
        }
    }
} 