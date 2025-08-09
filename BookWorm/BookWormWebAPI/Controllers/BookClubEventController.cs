using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,User")]
    public class BookClubEventController : BaseCRUDController<BookClubEventResponse, BookClubEventSearchObject, BookClubEventCreateUpdateRequest, BookClubEventCreateUpdateRequest>
    {
        private readonly IBookClubEventService _bookClubEventService;

        public BookClubEventController(IBookClubEventService bookClubEventService) : base(bookClubEventService)
        {
            _bookClubEventService = bookClubEventService;
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            {
                throw new UnauthorizedAccessException("User ID not found in claims");
            }
            return userId;
        }

        [HttpGet("")]
        public override async Task<PagedResult<BookClubEventResponse>> Get([FromQuery] BookClubEventSearchObject? search = null)
        {
            return await _bookClubEventService.GetAsync(search ?? new BookClubEventSearchObject());
        }

        [HttpGet("{id}")]
        public override async Task<BookClubEventResponse?> GetById(int id)
        {
            return await _bookClubEventService.GetByIdAsync(id);
        }

        [HttpPost]
        public override async Task<BookClubEventResponse> Create([FromBody] BookClubEventCreateUpdateRequest request)
        {
            return await _bookClubEventService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        public override async Task<BookClubEventResponse?> Update(int id, [FromBody] BookClubEventCreateUpdateRequest request)
        {
            var bookClubEvent = await _bookClubEventService.GetByIdAsync(id);
            if (bookClubEvent == null)
                return null;

            var currentUserId = GetCurrentUserId();
            if (bookClubEvent.CreatorId != currentUserId)
            {
                return null; 
            }

            return await _bookClubEventService.UpdateAsync(id, request);
        }

        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
        {
            var bookClubEvent = await _bookClubEventService.GetByIdAsync(id);
            if (bookClubEvent == null)
                return false;

            var currentUserId = GetCurrentUserId();
            if (bookClubEvent.CreatorId != currentUserId)
            {
                return false;
            }

            return await base.Delete(id);
        }

        [HttpPost("participate")]
        public async Task<ActionResult<bool>> ParticipateInEvent([FromBody] ParticipateInEventRequest request)
        {
            var result = await _bookClubEventService.ParticipateInEventAsync(request);
            return Ok(result);
        }

        [HttpPost("{id}/leave")]
        public async Task<ActionResult<bool>> LeaveEvent(int id)
        {
            var result = await _bookClubEventService.LeaveEventAsync(id);
            return Ok(result);
        }

        [HttpPost("{id}/complete")]
        public async Task<ActionResult<bool>> MarkEventAsCompleted(int id)
        {
            var result = await _bookClubEventService.MarkEventAsCompletedAsync(id);
            return Ok(result);
        }

        [HttpGet("bookclub/{bookClubId}")]
        public async Task<ActionResult<List<BookClubEventResponse>>> GetEventsByBookClub(int bookClubId)
        {
            var events = await _bookClubEventService.GetEventsByBookClubAsync(bookClubId);
            return Ok(events);
        }
    }
} 