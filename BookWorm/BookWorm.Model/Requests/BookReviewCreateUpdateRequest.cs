using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class BookReviewCreateUpdateRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int BookId { get; set; }

        [Required]
        [MaxLength(2000)]
        public string Review { get; set; } = string.Empty;

        [Required]
        [Range(1, 5)]
        public int Rating { get; set; }

        public bool IsChecked { get; set; } = false;
    }
} 