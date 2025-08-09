using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;
using BookWormWebAPI.Requests;
using BookWorm.Services.DataBase;
using Microsoft.AspNetCore.Hosting;
using System;
using System.IO;
using System.Security.Claims;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,User")]
    public class ReadingListController : ControllerBase
    {
        private readonly IReadingListService _readingListService;
        private readonly IWebHostEnvironment _env;
        private readonly BookWormDbContext _context;

        public ReadingListController(IReadingListService readingListService, IWebHostEnvironment env, BookWormDbContext context)
        {
            _readingListService = readingListService;
            _env = env;
            _context = context;
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
            var currentUserId = GetCurrentUserId();
            if (request.UserId != currentUserId)
            {
                return BadRequest("You can only edit your own reading lists");
            }

            var updatedList = await _readingListService.UpdateAsync(id, request);
            if (updatedList == null)
                return NotFound();
            return updatedList;
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            var list = await _readingListService.GetByIdAsync(id);
            if (list == null)
                return NotFound();

            var currentUserId = GetCurrentUserId();
            if (list.UserId != currentUserId)
            {
                return BadRequest("You can only delete your own reading lists");
            }

            var deleted = await _readingListService.DeleteAsync(id);
            if (!deleted)
                return NotFound();
            return NoContent();
        }

        [HttpPost("{id}/add-book")]
        public async Task<ActionResult<ReadingListResponse>> AddBookToList(int id, [FromBody] AddBookToListRequest request)
        {
            var list = await _readingListService.GetByIdAsync(id);
            if (list == null)
                return NotFound();

            var currentUserId = GetCurrentUserId();
            if (list.UserId != currentUserId)
            {
                return BadRequest("You can only add books to your own reading lists");
            }

            try
            {
                var result = await _readingListService.AddBookToListAsync(id, request.BookId, request.ReadAt);
                return Ok(result);
            }
            catch (BookWorm.Model.Exceptions.ReadingListException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpDelete("{id}/books/{bookId}")]
        public async Task<ActionResult<ReadingListResponse>> RemoveBookFromList(int id, int bookId)
        {
            var list = await _readingListService.GetByIdAsync(id);
            if (list == null)
                return NotFound();

            var currentUserId = GetCurrentUserId();
            if (list.UserId != currentUserId)
            {
                return BadRequest("You can only remove books from your own reading lists");
            }

            try
            {
                var result = await _readingListService.RemoveBookFromListAsync(id, bookId);
                return Ok(result);
            }
            catch (BookWorm.Model.Exceptions.ReadingListException ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("{id}/cover")]
        [RequestSizeLimit(10_000_000)]
        public async Task<ActionResult<ReadingListResponse>> UploadCover(int id, [FromForm] CoverUploadRequest request)
        {
            try
            {
                var coverImage = request.CoverImage;
                var list = await _readingListService.GetByIdAsync(id);
                if (list == null)
                    return NotFound($"Reading list with ID {id} not found");
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

                var listEntity = await _context.ReadingLists.FindAsync(id);
                if (listEntity != null)
                {
                    listEntity.CoverImagePath = $"covers/{fileName}";
                    await _context.SaveChangesAsync();
                    var updatedList = await _readingListService.GetByIdAsync(id);
                    return Ok(updatedList);
                }
                return NotFound($"Reading list entity with ID {id} not found in database");
            }
            catch (Exception ex)
            {
                return BadRequest($"Error uploading cover: {ex.Message}");
            }
        }
    }
} 