namespace BookWorm.Model.Requests
{
    public class UserFriendRequest
    {
        public int UserId { get; set; }
        public int FriendId { get; set; }
    }

    public class UpdateFriendshipStatusRequest
    {
        public int UserId { get; set; }
        public int FriendId { get; set; }
        public int Status { get; set; } // 0=Pending, 1=Accepted, 2=Declined, 3=Blocked
    }
} 