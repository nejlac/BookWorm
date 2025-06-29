using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IUserRoleService
    {
        Task<bool> IsUserAdminAsync(int userId);
        Task<int?> GetCurrentUserIdAsync();
    }
} 