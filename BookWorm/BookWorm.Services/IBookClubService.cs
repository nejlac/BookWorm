using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;

namespace BookWorm.Services
{
    public interface IBookClubService : ICRUDService<BookClubResponse, BookClubSearchObject, BookClubCreateUpdateRequest, BookClubCreateUpdateRequest>
    {
        Task<bool> JoinBookClubAsync(JoinBookClubRequest request);
        Task<bool> LeaveBookClubAsync(int bookClubId);
        Task<List<BookClubMemberResponse>> GetBookClubMembersAsync(int bookClubId);
        Task<bool> IsMemberAsync(int bookClubId, int userId);
        Task<bool> IsCreatorAsync(int bookClubId, int userId);
    }
} 