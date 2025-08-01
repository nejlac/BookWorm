using BookWorm.Model.Responses;

namespace BookWorm.Services
{
    public interface IReadingStreakService
    {
        Task<ReadingStreakResponse?> GetUserStreakAsync(int userId);
        Task<ReadingStreakResponse> UpdateStreakAsync(int userId);
        Task<ReadingStreakResponse> CreateStreakAsync(int userId);
        Task<bool> MarkReadingActivityAsync(int userId);
    }
} 