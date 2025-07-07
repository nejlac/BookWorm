using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using MapsterMapper;
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
    }
}
