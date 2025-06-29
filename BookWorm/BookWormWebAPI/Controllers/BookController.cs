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
    [Authorize(Roles = "Admin,User")]
    public class BookController : BaseCRUDController<BookResponse, BookSearchObject, BookCreateUpdateRequest, BookCreateUpdateRequest>
    {
        private readonly IBookService _bookService;

        public BookController(IBookService bookService) : base(bookService)
        {
            _bookService = bookService;
        }

        // Override GET endpoints to allow anonymous access for viewing books
        [HttpGet("")]
        [AllowAnonymous]
        public override async Task<PagedResult<BookResponse>> Get([FromQuery] BookSearchObject? search = null)
        {
            return await _bookService.GetAsync(search ?? new BookSearchObject());
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public override async Task<BookResponse?> GetById(int id)
        {
            return await _bookService.GetByIdAsync(id);
        }

        // State transition endpoints
        [HttpPost("{id}/accept")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<BookResponse>> AcceptBook(int id)
        {
            var book = await _bookService.AcceptBookAsync(id);
            if (book == null)
                return NotFound();
            return book;
        }

        [HttpPost("{id}/decline")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<BookResponse>> DeclineBook(int id)
        {
            var book = await _bookService.DeclineBookAsync(id);
            if (book == null)
                return NotFound();
            return book;
        }
    }
} 