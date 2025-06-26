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
    public class BookReviewController : ControllerBase
    {
        private readonly IBookReviewService _bookReviewService;

        public BookReviewController(IBookReviewService bookReviewService)
        {
            _bookReviewService = bookReviewService;
        }

        [HttpGet]
        public async Task<ActionResult<List<BookReviewResponse>>> Get([FromQuery] BookReviewSearchObject? search = null)
        {
            return await _bookReviewService.GetAsync(search ?? new BookReviewSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BookReviewResponse>> GetById(int id)
        {
            var review = await _bookReviewService.GetByIdAsync(id);
            if (review == null)
                return NotFound();
            return review;
        }

        [HttpPost]
        public async Task<ActionResult<BookReviewResponse>> Create(BookReviewCreateUpdateRequest request)
        {
            var createdReview = await _bookReviewService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdReview.Id }, createdReview);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<BookReviewResponse>> Update(int id, BookReviewCreateUpdateRequest request)
        {
            var updatedReview = await _bookReviewService.UpdateAsync(id, request);
            if (updatedReview == null)
                return NotFound();
            return updatedReview;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _bookReviewService.DeleteAsync(id);
            if (!deleted)
                return NotFound();
            return NoContent();
        }
    }
} 