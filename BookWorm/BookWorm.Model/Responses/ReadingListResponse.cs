using System;
using System.Collections.Generic;

namespace BookWorm.Model.Responses
{
    public class ReadingListResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool IsPublic { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<ReadingListBookResponse> Books { get; set; } = new List<ReadingListBookResponse>();
    }

    public class ReadingListBookResponse
    {
        public int BookId { get; set; }
        public string Title { get; set; } = string.Empty;
        public DateTime AddedAt { get; set; }
    }
} 