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
    public class BookController : ControllerBase
    {
        private readonly IBookService _bookService;

        public BookController(IBookService bookService)
        {
            _bookService = bookService;
        }

        [HttpGet]
        
        public async Task<ActionResult<List<BookResponse>>> Get([FromQuery] BookSearchObject? search = null)
        {
            return await _bookService.GetAsync(search ?? new BookSearchObject());
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BookResponse>> GetById(int id)
        {
            var book = await _bookService.GetByIdAsync(id);
            if (book == null)
                return NotFound();
            return book;
        }

        [HttpPost]
        public async Task<ActionResult<BookResponse>> Create(BookCreateUpdateRequest request)
        {
            var createdBook = await _bookService.CreateAsync(request);
            return CreatedAtAction(nameof(GetById), new { id = createdBook.Id }, createdBook);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<BookResponse>> Update(int id, BookCreateUpdateRequest request)
        {
            var updatedBook = await _bookService.UpdateAsync(id, request);
            if (updatedBook == null)
                return NotFound();
            return updatedBook;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _bookService.DeleteAsync(id);
            if (!deleted)
                return NotFound();
            return NoContent();
        }
    }
} 