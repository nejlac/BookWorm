using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReadingChallengeController : BaseCRUDController<ReadingChallengeResponse, ReadingChallengeSearchObject, ReadingChallengeCreateUpdateRequest, ReadingChallengeCreateUpdateRequest>
    {
        public ReadingChallengeController(IReadingChallengeService readingChallengeService) : base(readingChallengeService)
        {
        }

        [HttpGet]
        [Authorize(Roles = "Admin,User")]
        public override async Task<PagedResult<ReadingChallengeResponse>> Get([FromQuery] ReadingChallengeSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,User")]
        public override async Task<ReadingChallengeResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost]
        [Authorize(Roles = "User")]
        public override async Task<ReadingChallengeResponse> Create([FromBody] ReadingChallengeCreateUpdateRequest request)
        {
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "User")]
        public override async Task<ReadingChallengeResponse?> Update(int id, [FromBody] ReadingChallengeCreateUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "User")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }
    }
} 