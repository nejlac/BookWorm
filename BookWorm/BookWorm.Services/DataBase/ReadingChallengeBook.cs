using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookWorm.Services.DataBase
{
    public class ReadingChallengeBook
    {
        [Key]
        public int Id { get; set; }
        
        public int ReadingChallengeId { get; set; }

        [ForeignKey("ReadingChallengeId")]
        public ReadingChallenge ReadingChallenge { get; set; } = null!;
        
        public int BookId { get; set; }

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;
        
        public DateTime CompletedAt { get; set; } = DateTime.Now;
    }
} 