using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.IO;
using Microsoft.AspNetCore.Hosting;
using BookWormWebAPI.Requests;
using BookWorm.Services.DataBase;
using Microsoft.EntityFrameworkCore;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,User")]
    public class BookController : BaseCRUDController<BookResponse, BookSearchObject, BookCreateUpdateRequest, BookCreateUpdateRequest>
    {
        private readonly IBookService _bookService;
        private readonly IWebHostEnvironment _env;
        private readonly BookWormDbContext _context;

        public BookController(IBookService bookService, IWebHostEnvironment env, BookWormDbContext context) : base(bookService)
        {
            _bookService = bookService;
            _env = env;
            _context = context;
        }
        
        [HttpGet("")]
       
        public override async Task<PagedResult<BookResponse>> Get([FromQuery] BookSearchObject? search = null)
        {
            return await _bookService.GetAsync(search ?? new BookSearchObject());
        }

        [HttpGet("{id}")]
       
        public override async Task<BookResponse?> GetById(int id)
        {
            return await _bookService.GetByIdAsync(id);
        }

       

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


        [HttpPost]
        public override async Task<BookResponse> Create([FromBody] BookCreateUpdateRequest request)
        {
            return await _bookService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        public override async Task<BookResponse?> Update(int id, [FromBody] BookCreateUpdateRequest request)
        {
            return await _bookService.UpdateAsync(id, request);
        }

        [HttpPost("{id}/cover")]
        [RequestSizeLimit(10_000_000)]
        public async Task<ActionResult<BookResponse>> UploadCover(int id, [FromForm] CoverUploadRequest request)
        {
            try
            {
                var coverImage = request.CoverImage;
                var book = await _bookService.GetByIdAsync(id);
                if (book == null)
                    return NotFound($"Book with ID {id} not found");
                if (coverImage == null || coverImage.Length == 0)
                    return BadRequest("No file uploaded or file is empty.");

                // Save the image file
                var uploads = Path.Combine(_env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), "covers");
                if (!Directory.Exists(uploads))
                    Directory.CreateDirectory(uploads);
                var fileName = Guid.NewGuid() + Path.GetExtension(coverImage.FileName);
                var filePath = Path.Combine(uploads, fileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await coverImage.CopyToAsync(stream);
                }

                // Only update the CoverImagePath field
                var bookEntity = await _context.Books.FindAsync(id);
                if (bookEntity != null)
                {
                    bookEntity.CoverImagePath = $"covers/{fileName}";
                    await _context.SaveChangesAsync();
                    // Return the updated book
                    var updatedBook = await _bookService.GetByIdAsync(id);
                    return Ok(updatedBook);
                }
                return NotFound($"Book entity with ID {id} not found in database");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error uploading cover: {ex.Message}");
            }
        }

        // --- STATISTICS ENDPOINTS ---
        [HttpGet("most-read")]
        [AllowAnonymous]
        public async Task<ActionResult<List<MostReadBookResponse>>> GetMostReadBooks([FromQuery] int topN = 4)
        {
            var result = await _bookService.GetMostReadBooks(topN);
            return Ok(result);
        }

        [HttpGet("count")]
        [AllowAnonymous]
        public async Task<ActionResult<int>> GetBooksCount()
        {
            var count = await _bookService.GetBooksCount();
            return Ok(count);
        }

        [HttpGet("most-read-genres")]
        [AllowAnonymous]
        public async Task<ActionResult<List<GenreStatisticResponse>>> GetMostReadGenres([FromQuery] int topN = 3)
        {
            return await _bookService.GetMostReadGenres(topN);
        }

        [HttpGet("{id}/rating")]
        [AllowAnonymous]
        public async Task<ActionResult<BookRatingResponse>> GetBookRating(int id)
        {
            var rating = await _bookService.GetBookRatingAsync(id);
            if (rating == null)
                return NotFound($"Book with ID {id} not found");
            return rating;
        }
    }
} 