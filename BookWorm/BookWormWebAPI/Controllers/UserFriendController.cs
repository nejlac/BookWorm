using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize (Roles ="User")]
    public class UserFriendController : ControllerBase
    {
        private readonly IUserFriendService _userFriendService;

        public UserFriendController(IUserFriendService userFriendService)
        {
            _userFriendService = userFriendService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UserFriendResponse>>> Get([FromQuery] UserFriendSearchObject? search = null)
        {
            return await _userFriendService.GetAsync(search ?? new UserFriendSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserFriendResponse>> GetById(int id)
        {
            var userFriend = await _userFriendService.GetByIdAsync(id);

            if (userFriend == null)
                return NotFound();

            return userFriend;
        }

        [HttpPost("send-request")]
        public async Task<ActionResult<UserFriendResponse>> SendFriendRequest(UserFriendRequest request)
        {
            try
            {
                var result = await _userFriendService.SendFriendRequestAsync(request);
                return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("update-status")]
        public async Task<ActionResult<UserFriendResponse>> UpdateFriendshipStatus(UpdateFriendshipStatusRequest request)
        {
            try
            {
                var result = await _userFriendService.UpdateFriendshipStatusAsync(request);
                if (result == null)
                    return NotFound();

                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _userFriendService.DeleteAsync(id);

            if (!deleted)
                return NotFound();

            return NoContent();
        }

        [HttpGet("user/{userId}/friends")]
        public async Task<ActionResult<List<UserFriendResponse>>> GetUserFriends(int userId)
        {
            var friends = await _userFriendService.GetUserFriendsAsync(userId);
            return Ok(friends);
        }

        [HttpGet("user/{userId}/pending-requests")]
        public async Task<ActionResult<List<UserFriendResponse>>> GetPendingFriendRequests(int userId)
        {
            var pendingRequests = await _userFriendService.GetPendingFriendRequestsAsync(userId);
            return Ok(pendingRequests);
        }

        [HttpGet("user/{userId}/sent-requests")]
        public async Task<ActionResult<List<UserFriendResponse>>> GetSentFriendRequests(int userId)
        {
            var sentRequests = await _userFriendService.GetSentFriendRequestsAsync(userId);
            return Ok(sentRequests);
        }

        [HttpGet("friendship-status")]
        public async Task<ActionResult<FriendshipStatusResponse>> GetFriendshipStatus(
            [FromQuery] int userId, 
            [FromQuery] int friendId)
        {
            var status = await _userFriendService.GetFriendshipStatusAsync(userId, friendId);
            
            if (status == null)
                return NotFound();

            return Ok(status);
        }

        [HttpDelete("remove-friend")]
        public async Task<ActionResult> RemoveFriend([FromQuery] int userId, [FromQuery] int friendId)
        {
            var removed = await _userFriendService.RemoveFriendAsync(userId, friendId);

            if (!removed)
                return NotFound();

            return NoContent();
        }

        [HttpDelete("cancel-request")]
        public async Task<ActionResult> CancelFriendRequest([FromQuery] int userId, [FromQuery] int friendId)
        {
            var canceled = await _userFriendService.CancelFriendRequestAsync(userId, friendId);

            if (!canceled)
                return NotFound();

            return NoContent();
        }
    }
} 