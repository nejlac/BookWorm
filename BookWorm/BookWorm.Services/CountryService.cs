using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class CountryService : BaseCRUDService<CountryResponse, CountrySearchObject, Country, CountryCreateUpdateRequest, CountryCreateUpdateRequest>, ICountryService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<GenreService> _logger;

        public CountryService(BookWormDbContext context, IMapper mapper, ILogger<GenreService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }

        protected override IQueryable<Country> ApplyFilter(IQueryable<Country> query, CountrySearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(c => c.Name.ToLower().Contains(search.Name.ToLower()));
            return query;
        }

        public override async Task<bool> DeleteAsync(int id)
        {
            var country = await _context.Countries.FindAsync(id);
            if (country == null)
                return false;

            // Check if country has any authors
            var hasAuthors = await _context.Authors.AnyAsync(a => a.CountryId == id);
            if (hasAuthors)
                throw new Exception("Cannot delete country who is linked to one or more authors.");

            // Check if country has any users
            var hasUsers = await _context.Users.AnyAsync(u => u.CountryId == id);
            if (hasUsers)
                throw new Exception("Cannot delete country who is linked to one or more users.");

            await BeforeDelete(country);
            _context.Countries.Remove(country);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
