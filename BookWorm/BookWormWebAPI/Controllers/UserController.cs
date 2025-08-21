using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using BookWorm.Services.DataBase;
using BookWormWebAPI.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AllowAnonymous]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly IWebHostEnvironment _env;
        private readonly BookWormDbContext _context;
        public UsersController(IUserService userService, IWebHostEnvironment env, BookWormDbContext context)
        {
            _env = env;
            _context = context;
            _userService = userService;
        }


        [HttpGet]
        public async Task<ActionResult<PagedResult<UserResponse>>> Get([FromQuery] UserSearchObject? search = null)
        {
            return await _userService.GetAsync(search ?? new UserSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UserResponse>> GetById(int id)
        {
            var user = await _userService.GetByIdAsync(id);

            if (user == null)
                return NotFound();

            return user;
        }

        [HttpGet("check-username/{username}")]
        public async Task<ActionResult<bool>> CheckUsernameExists(string username)
        {
            var exists = await _userService.UsernameExistsAsync(username);
            return exists;
        }

        [HttpGet("check-email/{email}")]
        public async Task<ActionResult<bool>> CheckEmailExists(string email)
        {
            var exists = await _userService.EmailExistsAsync(email);
            return exists;
        }

        [HttpPost]
        public async Task<ActionResult<UserResponse>> Create(UserCreateUpdateRequest request)
        {
            var createdUser = await _userService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdUser.Id }, createdUser);
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

        [HttpPut("{id}")]
        public async Task<ActionResult<UserResponse>> Update(int id, UserCreateUpdateRequest request)
        {
            var isAdmin = User.IsInRole("Admin");
            var userEntity = await _context.Users.FindAsync(id);
            var isNewUser = userEntity != null && userEntity.CreatedAt != null && 
                           DateTime.UtcNow.Subtract(userEntity.CreatedAt).TotalMinutes <= 5;
            
            if (!isNewUser && !isAdmin)
            {
                try
                {
                    var currentUserId = GetCurrentUserId();
                    if (id != currentUserId)
                    {
                        return BadRequest("You can only edit your own profile");
                    }
                }
                catch (UnauthorizedAccessException)
                {
                    return BadRequest("You can only edit your own profile");
                }
            }

            var updatedUser = await _userService.UpdateAsync(id, request);

            if (updatedUser == null)
                return NotFound();

            return updatedUser;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var currentUserId = GetCurrentUserId();
            var isAdmin = User.IsInRole("Admin");
            
            if (id != currentUserId && !isAdmin)
            {
                return BadRequest("You can only delete your own profile");
            }

            var deleted = await _userService.DeleteAsync(id);

            if (!deleted)
                return NotFound();

            return NoContent();
        }

        [HttpPost("{id}/cover")]
        [RequestSizeLimit(10_000_000)]
        public async Task<ActionResult<UserResponse>> UploadCover(int id, [FromForm] CoverUploadRequest request)
        {
            try
            {
                var coverImage = request.CoverImage;
                var user = await _userService.GetByIdAsync(id);
                if (user == null)
                    return NotFound($"User with ID {id} not found");
                if (coverImage == null || coverImage.Length == 0)
                    return BadRequest("No file uploaded or file is empty.");

                var isAdmin = User.IsInRole("Admin");
                var userEntity = await _context.Users.FindAsync(id);
                var isNewUser = userEntity != null && userEntity.CreatedAt != null && 
                               DateTime.UtcNow.Subtract(userEntity.CreatedAt).TotalMinutes <= 5;
                
                if (!isNewUser && !isAdmin)
                {
                    try
                    {
                        var currentUserId = GetCurrentUserId();
                        if (id != currentUserId)
                        {
                            return BadRequest("You can only upload cover for your own profile");
                        }
                    }
                    catch (UnauthorizedAccessException)
                    {
                        return BadRequest("You can only upload cover for your own profile");
                    }
                }

                var uploads = Path.Combine(_env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), "covers");
                if (!Directory.Exists(uploads))
                    Directory.CreateDirectory(uploads);
                var fileName = Guid.NewGuid() + Path.GetExtension(coverImage.FileName);
                var filePath = Path.Combine(uploads, fileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await coverImage.CopyToAsync(stream);
                }

                var userEntityForUpdate = await _context.Users.FindAsync(id);
                if (userEntityForUpdate != null)
                {
                    userEntityForUpdate.PhotoUrl = $"covers/{fileName}";
                    await _context.SaveChangesAsync();

                    var updatedUser = await _userService.GetByIdAsync(id);
                    return Ok(updatedUser);
                }
                return NotFound($"User entity with ID {id} not found in database");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error uploading cover: {ex.Message}");
            }
        }

        [HttpGet("recommend-friends/{userId}")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> RecommendFriends(int userId)
        {
            var result = await _userService.RecommendFriends(userId);
            return Ok(result);
        }

        // --- STATISTICS ENDPOINTS ---
        [HttpGet("count")]
        [AllowAnonymous]
        public async Task<ActionResult<int>> GetUsersCount()
        {
            var count = await _userService.GetUsersCount();
            return Ok(count);
        }

        [HttpGet("age-distribution")]
        [AllowAnonymous]
        public async Task<ActionResult<List<AgeDistributionResponse>>> GetUserAgeDistribution()
        {
            return await _userService.GetUserAgeDistribution();
        }

        [HttpGet("{userId}/most-read-genres")]
        [AllowAnonymous]
        public async Task<ActionResult<List<GenreStatisticResponse>>> GetUserMostReadGenres(
            int userId,
            [FromQuery] int? year = null)
        {
            return await _userService.GetUserMostReadGenres(userId, year);
        }

        [HttpGet("{userId}/rating-statistics")]
        [AllowAnonymous]
        public async Task<ActionResult<UserRatingStatisticsResponse>> GetUserRatingStatistics(
            int userId,
            [FromQuery] int? year = null)
        {
            return await _userService.GetUserRatingStatistics(userId, year);
        }
    
        [HttpPost("login")]
    public async Task<ActionResult<UserResponse>> Login(UserLoginRequest request)
    {
        try
        {
            var user = await _userService.AuthenticateAsync(request);

            if (user == null)
            {
                return Unauthorized(new { message = "Invalid username or password" });
            }

            
            if (user.Roles == null || !user.Roles.Any())
            {
                return StatusCode(403, new { message = "Access denied. User has no roles assigned." });
            }
            
            if (!user.Roles.Any(r => r.Name == "User"))
            {
                
                return StatusCode(403, new { message = "Access denied. Only users with 'User' role can access the mobile app." });
            }

            return Ok(user);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Internal server error during login." });
        }
    }

    [HttpPost("admin-login")]
    public async Task<ActionResult<UserResponse>> AdminLogin(UserLoginRequest request)
    {
        try
        {
            var user = await _userService.AuthenticateAsync(request);

            if (user == null)
            {
                return Unauthorized(new { message = "Invalid username or password" });
            }
           

            // Only allow users with "Admin" role to access desktop app
            if (user.Roles == null || !user.Roles.Any())
            {
                return StatusCode(403, new { message = "Access denied. User has no roles assigned." });
            }
            
            if (!user.Roles.Any(r => r.Name == "Admin"))
            {
               
                return StatusCode(403, new { message = "Access denied. Only users with 'Admin' role can access the desktop app." });
            }

            return Ok(user);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Internal server error during login." });
        }
    }
    }
}

