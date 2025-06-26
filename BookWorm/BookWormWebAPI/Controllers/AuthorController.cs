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
    public class AuthorController : ControllerBase
    {
        private readonly IAuthorService _authorService;

        public AuthorController(IAuthorService authorService)
        {
            _authorService = authorService;
        }

        [HttpGet]
        public async Task<ActionResult<List<AuthorResponse>>> Get([FromQuery] AuthorSearchObject? search = null)
        {
            return await _authorService.GetAsync(search ?? new AuthorSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<AuthorResponse>> GetById(int id)
        {
            var author = await _authorService.GetByIdAsync(id);
            if (author == null)
                return NotFound();
            return author;
        }

        [HttpPost]
        public async Task<ActionResult<AuthorResponse>> Create(AuthorCreateUpdateRequest request)
        {
            var createdAuthor = await _authorService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdAuthor.Id }, createdAuthor);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<AuthorResponse>> Update(int id, AuthorCreateUpdateRequest request)
        {
            var updatedAuthor = await _authorService.UpdateAsync(id, request);
            if (updatedAuthor == null)
                return NotFound();
            return updatedAuthor;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _authorService.DeleteAsync(id);
            if (!deleted)
                return NotFound();
            return NoContent();
        }
    }
} 