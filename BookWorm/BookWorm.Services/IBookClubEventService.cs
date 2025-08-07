using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;

namespace BookWorm.Services
{
    public interface IBookClubEventService : ICRUDService<BookClubEventResponse, BookClubEventSearchObject, BookClubEventCreateUpdateRequest, BookClubEventCreateUpdateRequest>
    {
        Task<bool> ParticipateInEventAsync(ParticipateInEventRequest request);
        Task<bool> LeaveEventAsync(int eventId);
        Task<bool> MarkEventAsCompletedAsync(int eventId);
        Task<bool> IsParticipantAsync(int eventId, int userId);
        Task<bool> IsCreatorAsync(int eventId, int userId);
        Task<List<BookClubEventResponse>> GetEventsByBookClubAsync(int bookClubId);
    }
} 