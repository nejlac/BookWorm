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
    public class BookReviewController : BaseCRUDController<BookReviewResponse, BookReviewSearchObject, BookReviewCreateUpdateRequest, BookReviewCreateUpdateRequest>
    {
        public BookReviewController(IBookReviewService bookReviewService) : base(bookReviewService)
        {
        }

        [HttpGet]
        [Authorize(Roles = "Admin,User")]
        public override async Task<PagedResult<BookReviewResponse>> Get([FromQuery] BookReviewSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,User")]
        public override async Task<BookReviewResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost]
        [Authorize(Roles = "User")]
        public override async Task<BookReviewResponse> Create([FromBody] BookReviewCreateUpdateRequest request)
        {
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "User")]
        public override async Task<BookReviewResponse?> Update(int id, [FromBody] BookReviewCreateUpdateRequest request)
        {
            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,User")]
        public override async Task<bool> Delete(int id)
        {
            return await base.Delete(id);
        }

        [HttpPut("{id}/check")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<BookReviewResponse>> CheckReview(int id)
        {
            var review = await _crudService.GetByIdAsync(id);
            if (review == null)
                return NotFound();

            var updateRequest = new BookReviewCreateUpdateRequest
            {
                UserId = review.UserId,
                BookId = review.BookId,
                Review = review.Review,
                Rating = review.Rating,
                IsChecked = true
            };

            var updated = await _crudService.UpdateAsync(id, updateRequest);
            return Ok(updated);
        }
    }
} 