using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookWorm.Services.DataBase
{
    public class ReadingChallenge
    {
        [Key]
        public int Id { get; set; }
        
        public int UserId { get; set; }

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
        
        public int Goal { get; set; }
        
        public int NumberOfBooksRead { get; set; } = 0;
        public bool IsCompleted { get; set; } = false;

        public int Year { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        public DateTime UpdatedAt { get; set; } = DateTime.Now;
        
        
        public virtual ICollection<ReadingChallengeBook> ReadingChallengeBooks { get; set; } = new List<ReadingChallengeBook>();
    }
} 