using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReadingChallengeController : ControllerBase
    {
        private readonly IReadingChallengeService _readingChallengeService;

        public ReadingChallengeController(IReadingChallengeService readingChallengeService)
        {
            _readingChallengeService = readingChallengeService;
        }

        [HttpGet]
        public async Task<ActionResult<List<ReadingChallengeResponse>>> Get([FromQuery] ReadingChallengeSearchObject? search = null)
        {
            return await _readingChallengeService.GetAsync(search ?? new ReadingChallengeSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ReadingChallengeResponse>> GetById(int id)
        {
            var challenge = await _readingChallengeService.GetByIdAsync(id);
            if (challenge == null)
                return NotFound();
            return challenge;
        }

        [HttpPost]
        public async Task<ActionResult<ReadingChallengeResponse>> Create(ReadingChallengeCreateUpdateRequest request)
        {
            var createdChallenge = await _readingChallengeService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdChallenge.Id }, createdChallenge);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ReadingChallengeResponse>> Update(int id, ReadingChallengeCreateUpdateRequest request)
        {
            var updatedChallenge = await _readingChallengeService.UpdateAsync(id, request);
            if (updatedChallenge == null)
                return NotFound();
            return updatedChallenge;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _readingChallengeService.DeleteAsync(id);
            if (!deleted)
                return NotFound();
            return NoContent();
        }
    }
} 