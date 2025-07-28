using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using BookWorm.Services.DataBase;
using BookWormWebAPI.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,User")]
    public class AuthorController : BaseCRUDController<AuthorResponse, AuthorSearchObject, AuthorCreateUpdateRequest, AuthorCreateUpdateRequest>
    {
        private readonly IAuthorService _authorService;
        private readonly IWebHostEnvironment _env;
        private readonly BookWormDbContext _context;
        public AuthorController(IAuthorService authorService, IWebHostEnvironment env, BookWormDbContext context) : base(authorService)
        {
            _authorService = authorService;
            _env = env;
            _context = context;

        }

        [HttpGet("")]

        public override async Task<PagedResult<AuthorResponse>> Get([FromQuery] AuthorSearchObject? search = null)
        {
            return await _authorService.GetAsync(search ?? new AuthorSearchObject());
        }

        [HttpGet("{id}")]

        public override async Task<AuthorResponse?> GetById(int id)
        {
            return await _authorService.GetByIdAsync(id);
        }


        [HttpPost("{id}/accept")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<AuthorResponse>> AcceptAuthor(int id)
        {
            var author = await _authorService.AcceptAuthorAsync(id);
            if (author == null)
                return NotFound();
            return author;
        }

        [HttpPost("{id}/decline")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<AuthorResponse>> DeclineAuthor(int id)
        {
            var author = await _authorService.DeclineAuthorAsync(id);
            if (author == null)
                return NotFound();
            return author;
        }


        [HttpPost]
        public override async Task<AuthorResponse> Create([FromBody] AuthorCreateUpdateRequest request)
        {
            return await _authorService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        public override async Task<AuthorResponse?> Update(int id, [FromBody] AuthorCreateUpdateRequest request)
        {
            return await _authorService.UpdateAsync(id, request);
        }
        [HttpPost("{id}/cover")]
            [RequestSizeLimit(10_000_000)]
            public async Task<ActionResult<BookResponse>> UploadCover(int id, [FromForm] CoverUploadRequest request)
            {
                try
                {
                    var coverImage = request.CoverImage;
                    var book = await _authorService.GetByIdAsync(id);
                    if (book == null)
                        return NotFound($"Author with ID {id} not found");
                    if (coverImage == null || coverImage.Length == 0)
                        return BadRequest("No file uploaded or file is empty.");

                   
                    var uploads = Path.Combine(_env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), "covers");
                    if (!Directory.Exists(uploads))
                        Directory.CreateDirectory(uploads);
                    var fileName = Guid.NewGuid() + Path.GetExtension(coverImage.FileName);
                    var filePath = Path.Combine(uploads, fileName);
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await coverImage.CopyToAsync(stream);
                    }

                   
                    var authorEntity = await _context.Authors.FindAsync(id);
                    if (authorEntity != null)
                    {
                        authorEntity.PhotoUrl = $"covers/{fileName}";
                        await _context.SaveChangesAsync();
                        // Return the updated book
                        var updatedAuthor = await _authorService.GetByIdAsync(id);
                        return Ok(updatedAuthor);
                    }
                    return NotFound($"Author entity with ID {id} not found in database");
                }
                catch (Exception ex)
                {
                    return BadRequest($"Error uploading cover: {ex.Message}");
                }
            }
        }
    }
