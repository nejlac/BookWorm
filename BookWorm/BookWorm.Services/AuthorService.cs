using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using BookWorm.Services;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BookWorm.Model.Exceptions;


namespace BookWorm.Services
{
    public class AuthorService : BaseCRUDService<AuthorResponse, AuthorSearchObject, Author, AuthorCreateUpdateRequest, AuthorCreateUpdateRequest>, IAuthorService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<AuthorService> _logger;

        public AuthorService(BookWormDbContext context, IMapper mapper, ILogger<AuthorService> logger):base (context,mapper)
        {
            _context = context;
            _logger = logger;
        }

       
        protected override IQueryable<DataBase.Author> ApplyFilter(IQueryable<DataBase.Author> query, AuthorSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(a => a.Name.Contains(search.Name));
            if (search.CountryId.HasValue)
                query = query.Where(a => a.CountryId == search.CountryId);
            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(a => a.Name.Contains(search.FTS) || a.Biography.Contains(search.FTS));
            
            
            query = query.Include(a => a.Country).Include(a => a.Books);
            return query;
        }

       

        protected override async Task BeforeInsert(Author entity, AuthorCreateUpdateRequest request)
        {
            
            if (await _context.Authors.AnyAsync(a => 
                a.Name.ToLower().Trim() == request.Name.ToLower().Trim() && 
                a.DateOfBirth.Date == request.DateOfBirth.Date))
            {
                throw new AuthorException($"An author with the name '{request.Name}' and date of birth '{request.DateOfBirth:yyyy-MM-dd}' already exists.");
            }
            
           
            entity.CreatedAt = DateTime.Now;
            entity.UpdatedAt = DateTime.Now;
        }

        protected override async Task BeforeUpdate(Author entity, AuthorCreateUpdateRequest request)
        {
            
            if (await _context.Authors.AnyAsync(a => 
                a.Id != entity.Id &&
                a.Name.ToLower().Trim() == request.Name.ToLower().Trim() && 
                a.DateOfBirth.Date == request.DateOfBirth.Date))
            {
                throw new AuthorException($"An author with the name '{request.Name}' and date of birth '{request.DateOfBirth:yyyy-MM-dd}' already exists.");
            }
            
          
            entity.UpdatedAt = DateTime.Now;
        }

        public override async Task<AuthorResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Authors
                .Include(a => a.Country)
                .Include(a => a.Books)
                .FirstOrDefaultAsync(a => a.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }

      
    }
} 