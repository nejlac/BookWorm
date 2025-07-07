using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookWorm.Services.DataBase
{
    public class Author
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(255)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(1000)]
        public string Biography { get; set; }
        
        [MaxLength(255)]

        public DateTime DateOfBirth { get; set; }
        
        public DateTime? DateOfDeath { get; set; }
        public int CountryId { get; set; }
        [ForeignKey(nameof(CountryId))]
        public  Country? Country { get; set; }

        [MaxLength(255)]
        public string? Website { get; set; }
        
        [MaxLength(255)]
        public string? PhotoUrl { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        public DateTime UpdatedAt { get; set; } = DateTime.Now;
        
        
        public virtual ICollection<Book> Books { get; set; } = new List<Book>();
    }
} 