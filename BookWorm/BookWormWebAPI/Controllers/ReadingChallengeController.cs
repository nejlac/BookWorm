using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using BookWormWebAPI.Requests;
using System.Linq;
using Microsoft.EntityFrameworkCore;

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

        [HttpPost("add-book")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> AddBookToChallenge([FromBody] AddBookToChallengeRequest request)
        {
            var service = (IReadingChallengeService)base._crudService;
            await service.AddBookToChallengeAsync(request.UserId, request.Year, request.BookId, request.CompletedAt);
            return Ok();
        }

        [HttpDelete("remove-book")]
        [Authorize(Roles = "User")]
        public async Task<IActionResult> RemoveBookFromChallenge([FromBody] AddBookToChallengeRequest request)
        {
            var service = (IReadingChallengeService)base._crudService;
            await service.RemoveBookFromChallengeAsync(request.UserId, request.Year, request.BookId);
            return Ok();
        }

        [HttpGet("summary")]
        [Authorize(Roles = "Admin,User")]
        public async Task<IActionResult> GetSummary([FromQuery] int? year = null, [FromQuery] int topN = 3)
        {
            var service = (IReadingChallengeService)base._crudService;
            var summary = await service.GetSummaryAsync(year, topN);
            return Ok(summary);
        }
    }
} 