using BookWorm.Services.DataBase;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class UserRoleService : IUserRoleService
    {
        private readonly BookWormDbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public UserRoleService(BookWormDbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        public async Task<bool> IsUserAdminAsync(int userId)
        {
            return await _context.UserRoles
                .Include(ur => ur.Role)
                .AnyAsync(ur => ur.UserId == userId && ur.Role.Name == "Admin");
        }

        public async Task<int?> GetCurrentUserIdAsync()
        {
            var userClaim = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier);
            if (userClaim != null && int.TryParse(userClaim.Value, out int userId))
            {
                return userId;
            }
            return null;
        }
    }
} 