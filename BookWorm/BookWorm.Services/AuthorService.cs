using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class AuthorService : IAuthorService
    {
        private readonly BookWormDbContext _context;

        public AuthorService(BookWormDbContext context)
        {
            _context = context;
        }

        public async Task<List<AuthorResponse>> GetAsync(AuthorSearchObject search)
        {
            var query = _context.Authors.Include(a => a.Country).Include(a => a.Books).AsQueryable();

            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(a => a.Name.Contains(search.Name));
            if (search.CountryId.HasValue)
                query = query.Where(a => a.CountryId == search.CountryId);
            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(a => a.Name.Contains(search.FTS) || a.Biography.Contains(search.FTS));

            var authors = await query.ToListAsync();
            return authors.Select(MapToResponse).ToList();
        }

        public async Task<AuthorResponse?> GetByIdAsync(int id)
        {
            var author = await _context.Authors.Include(a => a.Country).Include(a => a.Books).FirstOrDefaultAsync(a => a.Id == id);
            return author != null ? MapToResponse(author) : null;
        }

        public async Task<AuthorResponse> CreateAsync(AuthorCreateUpdateRequest request)
        {
            var author = new Author
            {
                Name = request.Name,
                Biography = request.Biography,
                DateOfBirth = request.DateOfBirth,
                DateOfDeath = request.DateOfDeath,
                CountryId = request.CountryId,
                Website = request.Website,
                PhotoUrl = request.PhotoUrl,
                CreatedAt = DateTime.Now,
                UpdatedAt = DateTime.Now
            };

            _context.Authors.Add(author);
            await _context.SaveChangesAsync();

            return await GetAuthorResponseWithBooksAsync(author.Id);
        }

        public async Task<AuthorResponse?> UpdateAsync(int id, AuthorCreateUpdateRequest request)
        {
            var author = await _context.Authors.FindAsync(id);
            if (author == null)
                return null;

            author.Name = request.Name;
            author.Biography = request.Biography;
            author.DateOfBirth = request.DateOfBirth;
            author.DateOfDeath = request.DateOfDeath;
            author.CountryId = request.CountryId;
            author.Website = request.Website;
            author.PhotoUrl = request.PhotoUrl;
            author.UpdatedAt = DateTime.Now;

            await _context.SaveChangesAsync();
            return await GetAuthorResponseWithBooksAsync(author.Id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var author = await _context.Authors.FindAsync(id);
            if (author == null)
                return false;

            _context.Authors.Remove(author);
            await _context.SaveChangesAsync();
            return true;
        }

        private AuthorResponse MapToResponse(Author author)
        {
            return new AuthorResponse
            {
                Id = author.Id,
                Name = author.Name,
                Biography = author.Biography,
                DateOfBirth = author.DateOfBirth,
                DateOfDeath = author.DateOfDeath,
                CountryId = author.CountryId,
                CountryName = author.Country?.Name ?? string.Empty,
                PhotoUrl = author.PhotoUrl,
                CreatedAt = author.CreatedAt,
                UpdatedAt = author.UpdatedAt,
                Books = author.Books.Select(b => new AuthorBookResponse
                {
                    Id = b.Id,
                    Title = b.Title,
                    PublicationYear = b.PublicationYear,
                    PageCount = b.PageCount
                }).ToList()
            };
        }

        private async Task<AuthorResponse> GetAuthorResponseWithBooksAsync(int authorId)
        {
            var author = await _context.Authors.Include(a => a.Country).Include(a => a.Books).FirstOrDefaultAsync(a => a.Id == authorId);
            if (author == null)
                throw new InvalidOperationException("Author not found");
            return MapToResponse(author);
        }
    }
} 