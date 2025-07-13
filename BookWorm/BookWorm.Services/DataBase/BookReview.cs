using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookWorm.Services.DataBase
{
    public class BookReview
    {
        [Key]
        public int Id { get; set; }
        
        public int UserId { get; set; }

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
        
        public int BookId { get; set; }

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;
        
        [MaxLength(2000)]
        public string? Review { get; set; } = string.Empty;

        [Range(1, 5)]
        public int Rating { get; set; }
        public bool isChecked { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
} 