using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookWorm.Services.DataBase
{
    public class ReadingListBook
    {
        [Key]
        public int Id { get; set; }
        
        public int ReadingListId { get; set; }

        [ForeignKey("ReadingListId")]
        public ReadingList ReadingList { get; set; } = null!;
        
        public int BookId { get; set; }

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;
        
        public DateTime AddedAt { get; set; } = DateTime.Now;
    }
} 