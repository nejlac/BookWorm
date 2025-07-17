using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using BookWorm.Services;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BookWorm.Model.Exceptions;

namespace BookWorm.Services
{
    public class ReadingChallengeService : BaseCRUDService<ReadingChallengeResponse, ReadingChallengeSearchObject, ReadingChallenge, ReadingChallengeCreateUpdateRequest, ReadingChallengeCreateUpdateRequest>, IReadingChallengeService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<ReadingChallengeService> _logger;

        public ReadingChallengeService(BookWormDbContext context, IMapper mapper, ILogger<ReadingChallengeService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }

        protected override IQueryable<ReadingChallenge> ApplyFilter(IQueryable<ReadingChallenge> query, ReadingChallengeSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Username))
                query = query.Where(rc => rc.User.Username.Contains( search.Username));
            if (search.Year.HasValue)
                query = query.Where(rc => rc.Year == search.Year);
            if (search.IsCompleted.HasValue)
                query = query.Where(rc => rc.IsCompleted == search.IsCompleted);

            query = query.Include(rc => rc.User).Include(rc => rc.ReadingChallengeBooks).ThenInclude(rcb => rcb.Book);
            return query;
        }

        protected override ReadingChallengeResponse MapToResponse(ReadingChallenge entity)
        {
            return new ReadingChallengeResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                UserName = entity.User?.Username ?? string.Empty,
                Goal = entity.Goal,
                NumberOfBooksRead = entity.NumberOfBooksRead,
                Year = entity.Year,
                CreatedAt = entity.CreatedAt,
                UpdatedAt = entity.UpdatedAt,
                IsCompleted = entity.IsCompleted,
                Books = entity.ReadingChallengeBooks.Select(rcb => new ReadingChallengeBookResponse
                {
                    BookId = rcb.BookId,
                    Title = rcb.Book?.Title ?? string.Empty,
                    CompletedAt = rcb.CompletedAt
                }).ToList()
            };
        }

        protected override async Task BeforeInsert(ReadingChallenge entity, ReadingChallengeCreateUpdateRequest request)
        {
           
            if (await _context.ReadingChallenges.AnyAsync(rc => 
                rc.UserId == request.UserId && 
                rc.Year == request.Year))
            {
                throw new ReadingChallengeException($"A reading challenge for user and year {request.Year} already exists.");
            }

            if (request.Goal < 1 || request.Goal > 1000)
            {
                throw new ReadingChallengeException("Goal must be between 1 and 1000.");
            }

            
            if (request.Year < 2000 || request.Year > DateTime.Now.Year+1)
            {
                throw new ReadingChallengeException("Year must be between 2000 and the following year from now.");
            }

          
            entity.NumberOfBooksRead = 0;
            entity.IsCompleted = false;
            entity.CreatedAt = DateTime.Now;
            entity.UpdatedAt = DateTime.Now;
        }

        protected override async Task BeforeUpdate(ReadingChallenge entity, ReadingChallengeCreateUpdateRequest request)
        {
            if (await _context.ReadingChallenges.AnyAsync(rc => 
                rc.Id != entity.Id &&
                rc.UserId == request.UserId && 
                rc.Year == request.Year))
            {
                throw new ReadingChallengeException($"A reading challenge for user and year {request.Year} already exists.");
            }

           
            if (request.Goal < 1 || request.Goal > 1000)
            {
                throw new ReadingChallengeException("Goal must be between 1 and 1000.");
            }


            if (request.Year < 2000 || request.Year > DateTime.Now.Year + 1)
            {
                throw new ReadingChallengeException("Year must be between 2000 and the following year from now.");
            }

            entity.UpdatedAt = DateTime.Now;
        }

        public override async Task<ReadingChallengeResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.ReadingChallenges
                .Include(rc => rc.User)
                .Include(rc => rc.ReadingChallengeBooks)
                .ThenInclude(rcb => rcb.Book)
                .FirstOrDefaultAsync(rc => rc.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

        public override async Task<ReadingChallengeResponse> CreateAsync(ReadingChallengeCreateUpdateRequest request)
        {
            var result = await base.CreateAsync(request);
            
            if (request.BookIds != null && request.BookIds.Count > 0)
            {
                await AddBooksToChallenge(result.Id, request.BookIds);
                await UpdateChallengeProgress(result.Id);
            }
            
            return await GetByIdAsync(result.Id) ?? result;
        }

        public override async Task<ReadingChallengeResponse?> UpdateAsync(int id, ReadingChallengeCreateUpdateRequest request)
        {
            var result = await base.UpdateAsync(id, request);
            
            if (result != null)
            {
               
                await UpdateBooksInChallenge(id, request.BookIds ?? new List<int>());
                await UpdateChallengeProgress(id);
                
                return await GetByIdAsync(id) ?? result;
            }
            
            return result;
        }

        private async Task AddBooksToChallenge(int challengeId, List<int> bookIds)
        {
            foreach (var bookId in bookIds)
            {
                if (await _context.Books.AnyAsync(b => b.Id == bookId))
                {
                    var rcb = new ReadingChallengeBook 
                    { 
                        ReadingChallengeId = challengeId, 
                        BookId = bookId, 
                        CompletedAt = DateTime.Now 
                    };
                    _context.ReadingChallengeBooks.Add(rcb);
                }
            }
            await _context.SaveChangesAsync();
        }

        private async Task UpdateBooksInChallenge(int challengeId, List<int> newBookIds)
        {
           
            var existingBooks = await _context.ReadingChallengeBooks
                .Where(rcb => rcb.ReadingChallengeId == challengeId)
                .ToListAsync();
            _context.ReadingChallengeBooks.RemoveRange(existingBooks);
            
           
            await AddBooksToChallenge(challengeId, newBookIds);
        }

        private async Task UpdateChallengeProgress(int challengeId)
        {
            var challenge = await _context.ReadingChallenges.FindAsync(challengeId);
            if (challenge != null)
            {
                var bookCount = await _context.ReadingChallengeBooks
                    .CountAsync(rcb => rcb.ReadingChallengeId == challengeId);
                
                challenge.NumberOfBooksRead = bookCount;
                challenge.IsCompleted = bookCount >= challenge.Goal;
                
                await _context.SaveChangesAsync();
            }
        }

        public async Task AddBookToChallengeAsync(int userId, int year, int bookId, DateTime completedAt)
        {
            var challenge = await _context.ReadingChallenges
                .Include(rc => rc.ReadingChallengeBooks)
                .FirstOrDefaultAsync(rc => rc.UserId == userId && rc.Year == year);
            if (challenge == null)
                return; 
            if (challenge.ReadingChallengeBooks.Any(rcb => rcb.BookId == bookId))
                return; 
            var rcb = new ReadingChallengeBook
            {
                ReadingChallengeId = challenge.Id,
                BookId = bookId,
                CompletedAt = completedAt
            };
            _context.ReadingChallengeBooks.Add(rcb);
            await _context.SaveChangesAsync();
            await UpdateChallengeProgress(challenge.Id);
        }

        public async Task<ReadingChallengeSummaryResponse> GetSummaryAsync(int? year = null, int topN = 3)
        {
            var challengesQuery = _context.ReadingChallenges
                .Include(rc => rc.User)
                .Include(rc => rc.ReadingChallengeBooks)
                .AsQueryable();

            if (year.HasValue)
                challengesQuery = challengesQuery.Where(c => c.Year == year.Value);

            var challengeList = await challengesQuery.ToListAsync();
            var completedCount = challengeList.Count(c => c.IsCompleted);

            var topReaders = challengeList
                .GroupBy(c => c.UserId)
                .Select(g => new TopReaderDto
                {
                    UserId = g.Key,
                    Username = g.First().User.Username,
                    PhotoUrl = g.First().User.PhotoUrl,
                    NumberOfBooksRead = g.Sum(c => c.NumberOfBooksRead)
                })
                .OrderByDescending(x => x.NumberOfBooksRead)
                .Take(topN)
                .ToList();

            return new ReadingChallengeSummaryResponse
            {
                CompletedChallenges = completedCount,
                TopReaders = topReaders
            };
        }
    }
} 