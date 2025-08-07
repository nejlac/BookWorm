using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services.DataBase
{
    public class BookClubEventParticipant
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int UserId { get; set; }

        [ForeignKey(nameof(UserId))]
        public User User { get; set; } = null!;

        [Required]
        public int BookClubEventId { get; set; }

        [ForeignKey(nameof(BookClubEventId))]
        public BookClubEvent BookClubEvent { get; set; } = null!;

        [Required]
        public bool IsCompleted { get; set; } = false;
    }

}
