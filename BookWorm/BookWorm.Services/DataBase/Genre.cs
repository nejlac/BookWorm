using System.ComponentModel.DataAnnotations;

namespace BookWorm.Services.DataBase
{
    public class Genre
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string? Description { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        
        public virtual ICollection<BookGenre> BookGenres { get; set; } = new List<BookGenre>();
    }
} 