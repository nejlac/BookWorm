using System;
using System.Collections.Generic;

namespace BookWorm.Model.Responses
{
    public class BookClubResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public int CreatorId { get; set; }
        public string CreatorName { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public int MembersCount { get; set; }
        public int EventsCount { get; set; }
        public bool IsMember { get; set; }
        public bool IsCreator { get; set; }
    }
} 