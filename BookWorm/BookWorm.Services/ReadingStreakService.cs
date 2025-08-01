using BookWorm.Model.Responses;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BookWorm.Services
{
    public class ReadingStreakService : IReadingStreakService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<ReadingStreakService> _logger;

        public ReadingStreakService(BookWormDbContext context, ILogger<ReadingStreakService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<ReadingStreakResponse?> GetUserStreakAsync(int userId)
        {
            var streak = await _context.ReadingStreaks
                .Include(rs => rs.User)
                .FirstOrDefaultAsync(rs => rs.UserId == userId);

            if (streak == null)
                return null;

            var today = DateTime.Today;
            var lastReadingDate = streak.LastReadingDate.Date;
            var daysSinceLastReading = (today - lastReadingDate).Days;
            var isActiveToday = lastReadingDate == today;

            return new ReadingStreakResponse
            {
                Id = streak.Id,
                UserId = streak.UserId,
                UserName = streak.User?.Username ?? string.Empty,
                CurrentStreak = streak.CurrentStreak,
                LongestStreak = streak.LongestStreak,
                LastReadingDate = streak.LastReadingDate,
                CreatedAt = streak.CreatedAt,
                UpdatedAt = streak.UpdatedAt,
                IsActiveToday = isActiveToday,
                DaysSinceLastReading = daysSinceLastReading
            };
        }

        public async Task<ReadingStreakResponse> UpdateStreakAsync(int userId)
        {
            var streak = await _context.ReadingStreaks
                .Include(rs => rs.User)
                .FirstOrDefaultAsync(rs => rs.UserId == userId);

            if (streak == null)
            {
                return await CreateStreakAsync(userId);
            }

            var today = DateTime.Today;
            var lastReadingDate = streak.LastReadingDate.Date;
            var daysDifference = (today - lastReadingDate).Days;

            // If user read today, increment streak
            if (daysDifference == 0)
            {
                // Already marked for today
                return await GetUserStreakAsync(userId) ?? new ReadingStreakResponse();
            }
            // If user read yesterday, continue streak
            else if (daysDifference == 1)
            {
                streak.CurrentStreak++;
                streak.LastReadingDate = today;
            }
            // If more than 1 day gap, reset streak
            else
            {
                streak.CurrentStreak = 1;
                streak.LastReadingDate = today;
            }

            // Update longest streak if current is longer
            if (streak.CurrentStreak > streak.LongestStreak)
            {
                streak.LongestStreak = streak.CurrentStreak;
            }

            streak.UpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();

            return await GetUserStreakAsync(userId) ?? new ReadingStreakResponse();
        }

        public async Task<ReadingStreakResponse> CreateStreakAsync(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null)
                throw new Exception("User not found");

            var streak = new ReadingStreak
            {
                UserId = userId,
                CurrentStreak = 1,
                LongestStreak = 1,
                LastReadingDate = DateTime.Today,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.ReadingStreaks.Add(streak);
            await _context.SaveChangesAsync();

            return await GetUserStreakAsync(userId) ?? new ReadingStreakResponse();
        }

        public async Task<bool> MarkReadingActivityAsync(int userId)
        {
            try
            {
                await UpdateStreakAsync(userId);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error marking reading activity for user {UserId}", userId);
                return false;
            }
        }
    }
} 