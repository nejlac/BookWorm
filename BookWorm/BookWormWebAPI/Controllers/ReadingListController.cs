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
    [Authorize(Roles = "User")]
    public class ReadingListController : ControllerBase
    {
        private readonly IReadingListService _readingListService;

        public ReadingListController(IReadingListService readingListService)
        {
            _readingListService = readingListService;
        }

        [HttpGet]
        public async Task<ActionResult<List<ReadingListResponse>>> Get([FromQuery] ReadingListSearchObject? search = null)
        {
            return await _readingListService.GetAsync(search ?? new ReadingListSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ReadingListResponse>> GetById(int id)
        {
            var list = await _readingListService.GetByIdAsync(id);
            if (list == null)
                return NotFound();
            return list;
        }

        [HttpPost]
        public async Task<ActionResult<ReadingListResponse>> Create(ReadingListCreateUpdateRequest request)
        {
            var createdList = await _readingListService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdList.Id }, createdList);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<ReadingListResponse>> Update(int id, ReadingListCreateUpdateRequest request)
        {
            var updatedList = await _readingListService.UpdateAsync(id, request);
            if (updatedList == null)
                return NotFound();
            return updatedList;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _readingListService.DeleteAsync(id);
            if (!deleted)
                return NotFound();
            return NoContent();
        }
    }
} 