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
using BookWorm.Services.AuthorStateMachine;

namespace BookWorm.Services
{
    public class AuthorService : BaseCRUDService<AuthorResponse, AuthorSearchObject, Author, AuthorCreateUpdateRequest, AuthorCreateUpdateRequest>, IAuthorService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<AuthorService> _logger;
        private readonly IUserRoleService _userRoleService;
        private readonly BaseAuthorState _baseAuthorState;

        public AuthorService(BookWormDbContext context, IMapper mapper, ILogger<AuthorService> logger, IUserRoleService userRoleService, BaseAuthorState baseAuthorState)
            : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _userRoleService = userRoleService;
            _baseAuthorState = baseAuthorState;
        }
       
        protected override IQueryable<DataBase.Author> ApplyFilter(IQueryable<DataBase.Author> query, AuthorSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(a => a.Name.Contains(search.Name));
            if (search.CountryId.HasValue)
                query = query.Where(a => a.CountryId == search.CountryId);
            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(a => a.Name.Contains(search.FTS) || a.Biography.Contains(search.FTS));
            if (!string.IsNullOrEmpty(search.AuthorState))
                query = query.Where(a => a.AuthorState == search.AuthorState);
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
            var author = await _context.Authors
                .Include(a => a.Country)
                .Include(a => a.Books)
                .FirstOrDefaultAsync(a => a.Id == id);
            
            if (author == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (currentUserId.HasValue)
            {
                var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
                if (!isAdmin && author.AuthorState != "Accepted" && author.CreatedByUserId != currentUserId.Value)
                    return null;
            }

            return MapToResponse(author);
        }

        public override async Task<AuthorResponse> CreateAsync(AuthorCreateUpdateRequest request)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
                throw new AuthorException("User not authenticated.");
            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
            request.CreatedByUserId = currentUserId.Value;
            BaseAuthorState baseState = isAdmin
                ? _baseAuthorState.GetAuthorState("Accepted")
                : _baseAuthorState.GetAuthorState("Submitted");
            return await baseState.CreateAsync(request);
        }

        public override async Task<AuthorResponse?> UpdateAsync(int id, AuthorCreateUpdateRequest request)
        {
            var author = await _context.Authors.FindAsync(id);
            if (author == null)
                return null;
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
                throw new AuthorException("User not authenticated.");
            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
            if (!isAdmin)
                throw new AuthorException("Only admin can edit authors.");
            var baseState = _baseAuthorState.GetAuthorState(author.AuthorState);
            return await baseState.UpdateAsync(id, request);
        }

        public override async Task<PagedResult<AuthorResponse>> GetAsync(AuthorSearchObject search)
        {
            var query = _context.Set<Author>().AsQueryable();
            query = ApplyFilter(query, search);
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (currentUserId.HasValue)
            {
                var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
                if (!isAdmin)
                    query = query.Where(a => a.AuthorState == "Accepted" || a.CreatedByUserId == currentUserId.Value);
            }
            else
            {
                query = query.Where(a => a.AuthorState == "Accepted");
            }
            int? totalCount = null;
            if (search.IncludeTotalCount)
                totalCount = await query.CountAsync();
            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                if (search.PageSize.HasValue)
                    query = query.Take(search.PageSize.Value);
            }
            var list = await query.ToListAsync();
            return new PagedResult<AuthorResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var author = await _context.Authors.FindAsync(id);
            if (author == null)
                return false;
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
                throw new AuthorException("User not authenticated.");
            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
            if (!isAdmin)
                throw new AuthorException("Only admin can delete authors.");

            // 1. Delete all books for this author (and all related book data)
            var books = _context.Books.Where(b => b.AuthorId == id).ToList();
            foreach (var book in books)
            {
                // Remove related book data manually, as in BookService.DeleteAsync
                var reviews = _context.BookReviews.Where(r => r.BookId == book.Id);
                _context.BookReviews.RemoveRange(reviews);
                var bookGenres = _context.BookGenres.Where(bg => bg.BookId == book.Id);
                _context.BookGenres.RemoveRange(bookGenres);
                var readingListBooks = _context.ReadingListBooks.Where(rlb => rlb.BookId == book.Id);
                _context.ReadingListBooks.RemoveRange(readingListBooks);
                var challengeBooks = _context.ReadingChallengeBooks.Where(rcb => rcb.BookId == book.Id);
                _context.ReadingChallengeBooks.RemoveRange(challengeBooks);
                _context.Books.Remove(book);
            }

            await BeforeDelete(author);
            _context.Authors.Remove(author);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<AuthorResponse?> AcceptAuthorAsync(int id)
        {
            var author = await _context.Authors.FindAsync(id);
            if (author == null) return null;
            var baseState = _baseAuthorState.GetAuthorState(author.AuthorState);
            return await baseState.AcceptAsync(id);
        }

        public async Task<AuthorResponse?> DeclineAuthorAsync(int id)
        {
            var author = await _context.Authors.FindAsync(id);
            if (author == null) return null;
            var baseState = _baseAuthorState.GetAuthorState(author.AuthorState);
            return await baseState.DeclineAsync(id);
        }
    }
} 