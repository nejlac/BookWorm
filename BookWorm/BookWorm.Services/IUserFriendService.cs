using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;

namespace BookWorm.Services
{
    public interface IUserFriendService
    {
        Task<PagedResult<UserFriendResponse>> GetAsync(UserFriendSearchObject search);
        Task<UserFriendResponse?> GetByIdAsync(int id);
        Task<UserFriendResponse> SendFriendRequestAsync(UserFriendRequest request);
        Task<UserFriendResponse?> UpdateFriendshipStatusAsync(UpdateFriendshipStatusRequest request);
        Task<bool> DeleteAsync(int id);
        Task<List<UserFriendResponse>> GetUserFriendsAsync(int userId);
        Task<List<UserFriendResponse>> GetPendingFriendRequestsAsync(int userId);
        Task<List<UserFriendResponse>> GetSentFriendRequestsAsync(int userId);
        Task<FriendshipStatusResponse?> GetFriendshipStatusAsync(int userId, int friendId);
        Task<bool> RemoveFriendAsync(int userId, int friendId);
        Task<bool> CancelFriendRequestAsync(int userId, int friendId);
    }
} 