using System;

namespace BookWorm.Model.Responses
{
    public class UserFriendResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string UserPhotoUrl { get; set; } = string.Empty;
        public int FriendId { get; set; }
        public string FriendName { get; set; } = string.Empty;
        public string FriendPhotoUrl { get; set; } = string.Empty;
        public int Status { get; set; } // 0=Pending, 1=Accepted, 2=Declined, 3=Blocked
        public DateTime RequestedAt { get; set; }
    }

    public class FriendshipStatusResponse
    {
        public int UserId { get; set; }
        public int FriendId { get; set; }
        public int Status { get; set; }
        public DateTime RequestedAt { get; set; }
    }
} 