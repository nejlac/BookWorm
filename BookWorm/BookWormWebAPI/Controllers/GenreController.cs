using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using BookWorm.Services.DataBase;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin, User")]
    public class GenreController : BaseCRUDController<GenreResponse, GenreSearchObject, GenreCreateUpdateRequest, GenreCreateUpdateRequest>
    {
        private readonly BookWormDbContext _context;
        private readonly IGenreService _genreService;

        public GenreController(IGenreService genreService, BookWormDbContext context) : base(genreService)
        {
            _context = context;
            _genreService = genreService;
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Admin")]
        public override async Task<bool> Delete(int id)
        {
            try
            {
                return await _genreService.DeleteAsync(id);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
    }
} 