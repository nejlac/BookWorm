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

        public ReadingListService(BookWormDbContext context)
        {
            _context = context;
        }

        public async Task<List<ReadingListResponse>> GetAsync(ReadingListSearchObject search)
        {
            var query = _context.ReadingLists.Include(rl => rl.User).Include(rl => rl.ReadingListBooks).ThenInclude(rlb => rlb.Book).AsQueryable();
            if (search.UserId.HasValue)
                query = query.Where(rl => rl.UserId == search.UserId);
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(rl => rl.Name.Contains(search.Name));
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
            var list = new ReadingList
            {
                UserId = request.UserId,
                Name = request.Name,
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
                        var rlb = new ReadingListBook { ReadingListId = list.Id, BookId = bookId, AddedAt = DateTime.Now };
                        _context.ReadingListBooks.Add(rlb);
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
            list.Name = request.Name;
            list.IsPublic = request.IsPublic;
            var existingBooks = await _context.ReadingListBooks.Where(rlb => rlb.ReadingListId == id).ToListAsync();
            _context.ReadingListBooks.RemoveRange(existingBooks);
            if (request.BookIds != null && request.BookIds.Count > 0)
            {
                foreach (var bookId in request.BookIds)
                {
                    if (await _context.Books.AnyAsync(b => b.Id == bookId))
                    {
                        var rlb = new ReadingListBook { ReadingListId = list.Id, BookId = bookId, AddedAt = DateTime.Now };
                        _context.ReadingListBooks.Add(rlb);
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

        private ReadingListResponse MapToResponse(ReadingList list)
        {
            return new ReadingListResponse
            {
                Id = list.Id,
                UserId = list.UserId,
                UserName = list.User?.Username ?? string.Empty,
                Name = list.Name,
                IsPublic = list.IsPublic,
                CreatedAt = list.CreatedAt,
                Books = list.ReadingListBooks.Select(rlb => new ReadingListBookResponse
                {
                    BookId = rlb.BookId,
                    Title = rlb.Book?.Title ?? string.Empty,
                    AddedAt = rlb.AddedAt
                }).ToList()
            };
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