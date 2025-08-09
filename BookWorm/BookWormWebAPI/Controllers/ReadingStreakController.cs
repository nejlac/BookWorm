using BookWorm.Model.Responses;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,User")]
    public class ReadingStreakController : ControllerBase
    {
        private readonly IReadingStreakService _readingStreakService;

        public ReadingStreakController(IReadingStreakService readingStreakService)
        {
            _readingStreakService = readingStreakService;
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

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<ReadingStreakResponse>> GetUserStreak(int userId)
        {
            // Check if user is trying to view their own streak
            var currentUserId = GetCurrentUserId();
            if (userId != currentUserId)
            {
                return BadRequest("You can only view your own reading streak");
            }

            var streak = await _readingStreakService.GetUserStreakAsync(userId);
            
            if (streak == null)
                return NotFound();

            return Ok(streak);
        }

        [HttpPost("user/{userId}/mark-activity")]
        public async Task<ActionResult<ReadingStreakResponse>> MarkReadingActivity(int userId)
        {
            // Check if user is trying to mark activity for their own streak
            var currentUserId = GetCurrentUserId();
            if (userId != currentUserId)
            {
                return BadRequest("You can only mark activity for your own reading streak");
            }

            try
            {
                var streak = await _readingStreakService.UpdateStreakAsync(userId);
                return Ok(streak);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("user/{userId}/create")]
        public async Task<ActionResult<ReadingStreakResponse>> CreateStreak(int userId)
        {
            // Check if user is trying to create their own streak
            var currentUserId = GetCurrentUserId();
            if (userId != currentUserId)
            {
                return BadRequest("You can only create your own reading streak");
            }

            try
            {
                var streak = await _readingStreakService.CreateStreakAsync(userId);
                return CreatedAtAction(nameof(GetUserStreak), new { userId }, streak);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }
    }
} 