using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class BookReviewCreateUpdateRequest
    {
        [Required(ErrorMessage = "UserId is required.")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "BookId is required.")]
        public int BookId { get; set; }

        [Required(ErrorMessage = "Review text is required.")]
        [MaxLength(2000, ErrorMessage = "Review must not exceed 2000 characters.")]
        public string Review { get; set; } = string.Empty;

        [Required(ErrorMessage = "Rating is required.")]
        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5.")]
        public int Rating { get; set; }

        public bool IsChecked { get; set; } = false;

    }
} 