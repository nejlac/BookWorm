using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IUserService
    {
        Task<PagedResult<UserResponse>> GetAsync(UserSearchObject search);
        Task<UserResponse?> GetByIdAsync(int id);
        Task<UserResponse> CreateAsync(UserCreateUpdateRequest request);
        Task<UserResponse?> UpdateAsync(int id, UserCreateUpdateRequest request);
        Task<bool> DeleteAsync(int id);
        Task<UserResponse?> AuthenticateAsync(UserLoginRequest request);
        Task<List<AgeDistributionResponse>> GetUserAgeDistribution();
        Task<int> GetUsersCount();
        Task<List<GenreStatisticResponse>> GetUserMostReadGenres(int userId, int? year = null);
        Task<UserRatingStatisticsResponse> GetUserRatingStatistics(int userId, int? year = null);
        Task<List<UserResponse>> RecommendFriends(int userId);
    }
}
