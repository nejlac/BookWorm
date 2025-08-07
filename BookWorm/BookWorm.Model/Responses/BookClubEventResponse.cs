using System;
using System.Collections.Generic;

namespace BookWorm.Model.Responses
{
    public class BookClubEventResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public DateTime Deadline { get; set; }
        public int BookId { get; set; }
        public string BookTitle { get; set; } = string.Empty;
        public string BookAuthorName { get; set; } = string.Empty;
        public string BookCoverImagePath { get; set; } = string.Empty;
        public int BookClubId { get; set; }
        public string BookClubName { get; set; } = string.Empty;
        public int CreatorId { get; set; }
        public string CreatorName { get; set; } = string.Empty;
        public int ParticipantsCount { get; set; }
        public int CompletedParticipantsCount { get; set; }
        public bool IsParticipant { get; set; }
        public bool IsCompleted { get; set; }
        public bool IsCreator { get; set; }
    }
} 