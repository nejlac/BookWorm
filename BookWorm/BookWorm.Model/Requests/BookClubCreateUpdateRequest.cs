using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class BookClubCreateUpdateRequest
    {
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;
    }
} 