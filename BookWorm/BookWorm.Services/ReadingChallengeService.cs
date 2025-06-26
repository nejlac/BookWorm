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
    public class ReadingChallengeService : IReadingChallengeService
    {
        private readonly BookWormDbContext _context;

        public ReadingChallengeService(BookWormDbContext context)
        {
            _context = context;
        }

        public async Task<List<ReadingChallengeResponse>> GetAsync(ReadingChallengeSearchObject search)
        {
            var query = _context.ReadingChallenges.Include(rc => rc.User).Include(rc => rc.ReadingChallengeBooks).ThenInclude(rcb => rcb.Book).AsQueryable();
            if (search.UserId.HasValue)
                query = query.Where(rc => rc.UserId == search.UserId);
            if (search.Year.HasValue)
                query = query.Where(rc => rc.Year == search.Year);
            if (search.IsCompleted.HasValue)
                query = query.Where(rc => rc.IsCompleted == search.IsCompleted);
            var challenges = await query.ToListAsync();
            return challenges.Select(MapToResponse).ToList();
        }

        public async Task<ReadingChallengeResponse?> GetByIdAsync(int id)
        {
            var challenge = await _context.ReadingChallenges.Include(rc => rc.User).Include(rc => rc.ReadingChallengeBooks).ThenInclude(rcb => rcb.Book).FirstOrDefaultAsync(rc => rc.Id == id);
            return challenge != null ? MapToResponse(challenge) : null;
        }

        public async Task<ReadingChallengeResponse> CreateAsync(ReadingChallengeCreateUpdateRequest request)
        {
            var challenge = new ReadingChallenge
            {
                UserId = request.UserId,
                Goal = request.Goal,
                Year = request.Year,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };
            _context.ReadingChallenges.Add(challenge);
            await _context.SaveChangesAsync();
            if (request.BookIds != null && request.BookIds.Count > 0)
            {
                foreach (var bookId in request.BookIds)
                {
                    if (await _context.Books.AnyAsync(b => b.Id == bookId))
                    {
                        var rcb = new ReadingChallengeBook { ReadingChallengeId = challenge.Id, BookId = bookId, CompletedAt = DateTime.Now };
                        _context.ReadingChallengeBooks.Add(rcb);
                    }
                }
                await _context.SaveChangesAsync();
            }
            var bookCount = await _context.ReadingChallengeBooks.CountAsync(rcb => rcb.ReadingChallengeId == challenge.Id);
            challenge.NumberOfBooksRead = bookCount;
            challenge.IsCompleted = bookCount >= challenge.Goal;
            await _context.SaveChangesAsync();
            return await GetReadingChallengeResponseWithBooksAsync(challenge.Id);
        }

        public async Task<ReadingChallengeResponse?> UpdateAsync(int id, ReadingChallengeCreateUpdateRequest request)
        {
            var challenge = await _context.ReadingChallenges.FindAsync(id);
            if (challenge == null)
                return null;
            challenge.Goal = request.Goal;
            challenge.Year = request.Year;
            challenge.UpdatedAt = DateTime.Now;
            var existingBooks = await _context.ReadingChallengeBooks.Where(rcb => rcb.ReadingChallengeId == id).ToListAsync();
            _context.ReadingChallengeBooks.RemoveRange(existingBooks);
            if (request.BookIds != null && request.BookIds.Count > 0)
            {
                foreach (var bookId in request.BookIds)
                {
                    if (await _context.Books.AnyAsync(b => b.Id == bookId))
                    {
                        var rcb = new ReadingChallengeBook { ReadingChallengeId = challenge.Id, BookId = bookId, CompletedAt = DateTime.Now };
                        _context.ReadingChallengeBooks.Add(rcb);
                    }
                }
            }
            await _context.SaveChangesAsync();
            var bookCount = await _context.ReadingChallengeBooks.CountAsync(rcb => rcb.ReadingChallengeId == challenge.Id);
            challenge.NumberOfBooksRead = bookCount;
            challenge.IsCompleted = bookCount >= challenge.Goal;
            await _context.SaveChangesAsync();
            return await GetReadingChallengeResponseWithBooksAsync(challenge.Id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var challenge = await _context.ReadingChallenges.FindAsync(id);
            if (challenge == null)
                return false;
            _context.ReadingChallenges.Remove(challenge);
            await _context.SaveChangesAsync();
            return true;
        }

        private ReadingChallengeResponse MapToResponse(ReadingChallenge challenge)
        {
            return new ReadingChallengeResponse
            {
                Id = challenge.Id,
                UserId = challenge.UserId,
                UserName = challenge.User?.Username ?? string.Empty,
                Goal = challenge.Goal,
                NumberOfBooksRead = challenge.NumberOfBooksRead,
                Year = challenge.Year,
                CreatedAt = challenge.CreatedAt,
                UpdatedAt = challenge.UpdatedAt,
                IsCompleted = challenge.IsCompleted,
                Books = challenge.ReadingChallengeBooks.Select(rcb => new ReadingChallengeBookResponse
                {
                    BookId = rcb.BookId,
                    Title = rcb.Book?.Title ?? string.Empty,
                    CompletedAt = rcb.CompletedAt
                }).ToList()
            };
        }

        private async Task<ReadingChallengeResponse> GetReadingChallengeResponseWithBooksAsync(int challengeId)
        {
            var challenge = await _context.ReadingChallenges.Include(rc => rc.User).Include(rc => rc.ReadingChallengeBooks).ThenInclude(rcb => rcb.Book).FirstOrDefaultAsync(rc => rc.Id == challengeId);
            if (challenge == null)
                throw new InvalidOperationException("ReadingChallenge not found");
            return MapToResponse(challenge);
        }
    }
} 