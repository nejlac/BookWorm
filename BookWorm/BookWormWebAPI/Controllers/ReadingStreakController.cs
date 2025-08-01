using BookWorm.Model.Responses;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AllowAnonymous]
    public class ReadingStreakController : ControllerBase
    {
        private readonly IReadingStreakService _readingStreakService;

        public ReadingStreakController(IReadingStreakService readingStreakService)
        {
            _readingStreakService = readingStreakService;
        }

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<ReadingStreakResponse>> GetUserStreak(int userId)
        {
            var streak = await _readingStreakService.GetUserStreakAsync(userId);
            
            if (streak == null)
                return NotFound();

            return Ok(streak);
        }

        [HttpPost("user/{userId}/mark-activity")]
        public async Task<ActionResult<ReadingStreakResponse>> MarkReadingActivity(int userId)
        {
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