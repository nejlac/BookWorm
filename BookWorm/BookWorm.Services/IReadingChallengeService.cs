using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;
using System;

namespace BookWorm.Services
{
    public interface IReadingChallengeService : ICRUDService<ReadingChallengeResponse, ReadingChallengeSearchObject, ReadingChallengeCreateUpdateRequest, ReadingChallengeCreateUpdateRequest>
    {
        Task AddBookToChallengeAsync(int userId, int year, int bookId, DateTime completedAt);
        Task RemoveBookFromChallengeAsync(int userId, int year, int bookId);
        Task<ReadingChallengeSummaryResponse> GetSummaryAsync(int? year = null, int topN = 3);
    }
} 