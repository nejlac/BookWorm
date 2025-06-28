using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IReadingChallengeService : ICRUDService<ReadingChallengeResponse, ReadingChallengeSearchObject, ReadingChallengeCreateUpdateRequest, ReadingChallengeCreateUpdateRequest>
    {
    }
} 