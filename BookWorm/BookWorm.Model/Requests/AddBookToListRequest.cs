using System;

namespace BookWorm.Model.Requests
{
    public class AddBookToListRequest
    {
        public int BookId { get; set; }
        public DateTime? ReadAt { get; set; }
    }
} 