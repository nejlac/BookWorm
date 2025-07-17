using System;
using System.Collections.Generic;

namespace BookWorm.Model.Responses
{
    public class ReadingChallengeResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public int Goal { get; set; }
        public int NumberOfBooksRead { get; set; }
        public int Year { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public bool IsCompleted { get; set; }
        public List<ReadingChallengeBookResponse> Books { get; set; } = new List<ReadingChallengeBookResponse>();
    }

    public class ReadingChallengeBookResponse
    {
        public int BookId { get; set; }
        public string Title { get; set; } = string.Empty;
        public DateTime CompletedAt { get; set; }
    }

    public class ReadingChallengeSummaryResponse
    {
        public int CompletedChallenges { get; set; }
        public List<TopReaderDto> TopReaders { get; set; } = new List<TopReaderDto>();
    }

    public class TopReaderDto
    {
        public int UserId { get; set; }
        public string Username { get; set; } = string.Empty;
        public string? PhotoUrl { get; set; }
        public int NumberOfBooksRead { get; set; }
    }
} 