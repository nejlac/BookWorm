using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class GenreService : BaseCRUDService<GenreResponse, GenreSearchObject, Genre, GenreCreateUpdateRequest, GenreCreateUpdateRequest>, IGenreService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<GenreService> _logger;

        public GenreService(BookWormDbContext context, IMapper mapper, ILogger<GenreService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }

        protected override IQueryable<Genre> ApplyFilter(IQueryable<Genre> query, GenreSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(g => g.Name.ToLower().Contains(search.Name.ToLower()));
            return query;
        }

        protected override async Task BeforeInsert(Genre entity, GenreCreateUpdateRequest request)
        {
            if (await _context.Genres.AnyAsync(g => g.Name.ToLower().Trim() == request.Name.ToLower().Trim()))
            {
                throw new Exception($"A genre with the name '{request.Name}' already exists.");
            }
            entity.CreatedAt = DateTime.Now;
        }

        protected override async Task BeforeUpdate(Genre entity, GenreCreateUpdateRequest request)
        {
            if (await _context.Genres.AnyAsync(g => g.Id != entity.Id && g.Name.ToLower().Trim() == request.Name.ToLower().Trim()))
            {
                throw new Exception($"A genre with the name '{request.Name}' already exists.");
            }
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var genre = await _context.Genres.FindAsync(id);
            if (genre == null)
                return false;

            var hasBooks = await _context.BookGenres.AnyAsync(bg => bg.GenreId == id);
            if (hasBooks)
                throw new Exception("Cannot delete genre who is linked to one or more books.");

            await BeforeDelete(genre);
            _context.Genres.Remove(genre);
            await _context.SaveChangesAsync();
            return true;
        }
    }
} 