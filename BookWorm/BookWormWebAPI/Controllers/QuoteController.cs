using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Security.Claims;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class QuoteController : BaseCRUDController<QuoteResponse, QuoteSearchObject, QuoteCreateUpdateRequest, QuoteCreateUpdateRequest>
    {
        public QuoteController(IQuoteService quoteService) : base(quoteService)
        {
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
            if (userIdClaim == null || !int.TryParse(userIdClaim.Value, out int userId))
            {
                throw new UnauthorizedAccessException("User ID not found in claims");
            }
            return userId;
        }

        [HttpGet]
        [Authorize(Roles = "Admin,User")]
        public override async Task<PagedResult<QuoteResponse>> Get([FromQuery] QuoteSearchObject? search = null)
        {
            return await base.Get(search);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Admin,User")]
        public override async Task<QuoteResponse?> GetById(int id)
        {
            return await base.GetById(id);
        }

        [HttpPost]
        [Authorize(Roles = "User")]
        public override async Task<QuoteResponse> Create([FromBody] QuoteCreateUpdateRequest request)
        {
            return await base.Create(request);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "User")]
        public override async Task<QuoteResponse?> Update(int id, [FromBody] QuoteCreateUpdateRequest request)
        {
            var currentUserId = GetCurrentUserId();
            if (request.UserId != currentUserId)
            {
                return null; 
            }

            return await base.Update(id, request);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin,User")]
        public override async Task<bool> Delete(int id)
        {
            var quote = await base.GetById(id);
            if (quote == null)
                return false;

            var currentUserId = GetCurrentUserId();
            if (quote.UserId != currentUserId)
            {
                return false;
            }

            return await base.Delete(id);
        }
    }
} 