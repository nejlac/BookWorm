using System;

namespace BookWorm.Model.Requests
{
    public class AddBookToChallengeRequest
    {
        public int UserId { get; set; }
        public int Year { get; set; }
        public int BookId { get; set; }
        public DateTime CompletedAt { get; set; }
    }
} 