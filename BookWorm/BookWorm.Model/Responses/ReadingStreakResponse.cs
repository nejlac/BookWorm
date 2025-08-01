using System;

namespace BookWorm.Model.Responses
{
    public class ReadingStreakResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int CurrentStreak { get; set; }
        public int LongestStreak { get; set; }
        public DateTime LastReadingDate { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsActiveToday { get; set; }
        public int DaysSinceLastReading { get; set; }
    }
} 