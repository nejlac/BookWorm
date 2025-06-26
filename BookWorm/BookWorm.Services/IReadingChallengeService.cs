using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IReadingChallengeService
    {
        Task<List<ReadingChallengeResponse>> GetAsync(ReadingChallengeSearchObject search);
        Task<ReadingChallengeResponse?> GetByIdAsync(int id);
        Task<ReadingChallengeResponse> CreateAsync(ReadingChallengeCreateUpdateRequest request);
        Task<ReadingChallengeResponse?> UpdateAsync(int id, ReadingChallengeCreateUpdateRequest request);
        Task<bool> DeleteAsync(int id);
    }
} 