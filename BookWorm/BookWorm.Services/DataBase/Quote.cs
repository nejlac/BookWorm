using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services.DataBase
{
    public class Quote
    {
        [Key]
        public int Id { get; set; }

        public int? UserId { get; set; }

        [ForeignKey("UserId")]
        public User? User { get; set; } = null!;

        public int BookId { get; set; }

        [ForeignKey("BookId")]
        public Book Book { get; set; } = null!;

        [MaxLength(10000)]
        public string QuoteText { get; set; } = string.Empty;
    }
}
