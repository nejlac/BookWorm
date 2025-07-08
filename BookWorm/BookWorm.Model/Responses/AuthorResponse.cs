using System;
using System.Collections.Generic;

namespace BookWorm.Model.Responses
{
    public class AuthorResponse
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Biography { get; set; } = string.Empty;
        public DateTime DateOfBirth { get; set; }
        public DateTime? DateOfDeath { get; set; }
        public int CountryId { get; set; }
        public string CountryName { get; set; } = string.Empty;
        public string? PhotoUrl { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string AuthorState { get; set; } = string.Empty;
        public int? CreatedByUserId { get; set; }
        public string CreatedByUserName { get; set; } = string.Empty;
        public List<AuthorBookResponse> Books { get; set; } = new List<AuthorBookResponse>();
    }

    public class AuthorBookResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int PublicationYear { get; set; }
        public int PageCount { get; set; }
    }
} 