using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookWorm.Services.DataBase
{
    public class Book
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(255)]
        public string Title { get; set; } = string.Empty;
        
        public int AuthorId { get; set; }

        [ForeignKey("AuthorId")]
        public Author Author { get; set; } = null!;
        
        [MaxLength(1000)]
        public string Description { get; set; }=string.Empty;

        public int PublicationYear { get; set; }
        
        public int PageCount { get; set; }
        
   
        public string? CoverImagePath { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        public DateTime UpdatedAt { get; set; } = DateTime.Now;
        
        public int? CreatedByUserId { get; set; }
        
        [ForeignKey("CreatedByUserId")]
        public User? CreatedByUser { get; set; }
       
        public virtual ICollection<BookGenre> BookGenres { get; set; } = new List<BookGenre>();
        public virtual ICollection<BookReview> BookReviews { get; set; } = new List<BookReview>();
        public virtual ICollection<ReadingListBook> ReadingListBooks { get; set; } = new List<ReadingListBook>();
        public virtual ICollection<ReadingChallengeBook> ReadingChallengeBooks { get; set; } = new List<ReadingChallengeBook>();
        [MaxLength(1000)]
        public string BookState { get; set; } = "Initial";
    }
} 