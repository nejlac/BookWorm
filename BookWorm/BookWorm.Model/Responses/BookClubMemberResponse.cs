using System;

namespace BookWorm.Model.Responses
{
    public class BookClubMemberResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public DateTime JoinedAt { get; set; }
    }
} 