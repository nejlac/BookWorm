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

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "User")]
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

        [HttpPost("{id}/add-book")]
        public async Task<ActionResult<ReadingListResponse>> AddBookToList(int id, [FromBody] AddBookToListRequest request)
        {
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
                var listEntity = await _context.ReadingLists.FindAsync(id);
                if (listEntity != null)
                {
                    listEntity.CoverImagePath = $"covers/{fileName}";
                    await _context.SaveChangesAsync();
                    // Return the updated list
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