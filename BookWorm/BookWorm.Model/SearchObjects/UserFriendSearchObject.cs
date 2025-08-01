namespace BookWorm.Model.SearchObjects
{
    public class UserFriendSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? FriendId { get; set; }
        public int? Status { get; set; } // 0=Pending, 1=Accepted, 2=Declined, 3=Blocked
    }
} 