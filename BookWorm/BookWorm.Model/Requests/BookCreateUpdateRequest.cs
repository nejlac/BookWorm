using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class BookCreateUpdateRequest
    {
        [Required]
        [MaxLength(255)]
        public string Title { get; set; } = string.Empty;

        [Required]
        public int AuthorId { get; set; }

        [MaxLength(1000)]
        public string Description { get; set; } = string.Empty;

        public int PublicationYear { get; set; }

        public int PageCount { get; set; }

        public byte[]? CoverImageUrl { get; set; }

        public List<int> GenreIds { get; set; } = new List<int>();
    }
} 