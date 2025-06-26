using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace BookWorm.Services.DataBase
{
    public enum FriendshipStatus
    {
        Pending = 0,
        Accepted = 1,
        Declined = 2,
        Blocked = 3
    }

    public class UserFriend
    {
        [Key]
        public int Id { get; set; }
        
        public int UserId { get; set; } // The user who sent the friend request

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
        
        public int FriendId { get; set; } // The user who received the friend request

        [ForeignKey("FriendId")]
        public User Friend { get; set; } = null!;
        
        public FriendshipStatus Status { get; set; } = FriendshipStatus.Pending;
        
        public DateTime RequestedAt { get; set; } = DateTime.Now;
       
    }
} 