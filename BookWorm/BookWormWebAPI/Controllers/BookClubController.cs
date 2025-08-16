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
    public class BookClubController : BaseCRUDController<BookClubResponse, BookClubSearchObject, BookClubCreateUpdateRequest, BookClubCreateUpdateRequest>
    {
        private readonly IBookClubService _bookClubService;
        private readonly IUserRoleService _userRoleService;

        public BookClubController(IBookClubService bookClubService, IUserRoleService userRoleService) : base(bookClubService)
        {
            _bookClubService = bookClubService;
            _userRoleService = userRoleService;
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
        public override async Task<PagedResult<BookClubResponse>> Get([FromQuery] BookClubSearchObject? search = null)
        {
            return await _bookClubService.GetAsync(search ?? new BookClubSearchObject());
        }

        [HttpGet("{id}")]
        public override async Task<BookClubResponse?> GetById(int id)
        {
            return await _bookClubService.GetByIdAsync(id);
        }

        [HttpPost]
        public override async Task<BookClubResponse> Create([FromBody] BookClubCreateUpdateRequest request)
        {
            return await _bookClubService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        public override async Task<BookClubResponse?> Update(int id, [FromBody] BookClubCreateUpdateRequest request)
        {
            var bookClub = await _bookClubService.GetByIdAsync(id);
            if (bookClub == null)
                return null;

            var currentUserId = GetCurrentUserId();
            if (bookClub.CreatorId != currentUserId)
            {
                return null; 
            }

            return await _bookClubService.UpdateAsync(id, request);
        }

        [HttpPost("join")]
        public async Task<ActionResult<bool>> JoinBookClub([FromBody] JoinBookClubRequest request)
        {
            var result = await _bookClubService.JoinBookClubAsync(request);
            return Ok(result);
        }

        [HttpPost("{id}/leave")]
        public async Task<ActionResult<bool>> LeaveBookClub(int id)
        {
            var result = await _bookClubService.LeaveBookClubAsync(id);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
        {
            var bookClub = await _bookClubService.GetByIdAsync(id);
            if (bookClub == null)
                return false;

            var currentUserId = GetCurrentUserId();
            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId);
            
            // Allow deletion if user is the creator or if user is admin
            if (bookClub.CreatorId != currentUserId && !isAdmin)
            {
                return false; 
            }

            return await base.Delete(id);
        }

        [HttpGet("{id}/members")]
        public async Task<ActionResult<List<BookClubMemberResponse>>> GetBookClubMembers(int id)
        {
            var members = await _bookClubService.GetBookClubMembersAsync(id);
            return Ok(members);
        }
    }
} 