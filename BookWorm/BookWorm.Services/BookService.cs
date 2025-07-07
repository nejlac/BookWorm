using BookWorm.Model.Exceptions;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using BookWorm.Services.BookStateMachine;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class BookService : BaseCRUDService<BookResponse, BookSearchObject, Book, BookCreateUpdateRequest, BookCreateUpdateRequest>, IBookService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<BookService> _logger;
        private readonly IUserRoleService _userRoleService;
        private readonly BaseBookState _baseBookState;

        public BookService(BookWormDbContext context, IMapper mapper, ILogger<BookService> logger, IUserRoleService userRoleService, BaseBookState baseBookState) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _userRoleService = userRoleService;
            _baseBookState = baseBookState;
        }

        protected override IQueryable<Book> ApplyFilter(IQueryable<Book> query, BookSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Title))
                query = query.Where(b => b.Title.Contains(search.Title));
            if (!string.IsNullOrEmpty(search.Author))
                query = query.Where(b => b.Author.Name.Contains(search.Author));
            if (search.GenreId.HasValue)
                query = query.Where(b => b.BookGenres.Any(bg => bg.GenreId == search.GenreId));
            if (search.PublicationYear.HasValue)
                query = query.Where(b => b.PublicationYear == search.PublicationYear);
            if (search.RPageCount.HasValue)
                query = query.Where(b => b.PageCount == search.RPageCount);
            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(b => b.Title.Contains(search.FTS) || b.Description.Contains(search.FTS) || b.Author.Name.Contains(search.FTS));
            if(!string.IsNullOrEmpty(search.Status))
                query = query.Where(b => b.BookState == search.Status);

            query = query.Include(b => b.Author)
                        .Include(b => b.BookGenres)
                        .ThenInclude(bg => bg.Genre)
                        .Include(b => b.CreatedByUser);
            return query;
        }

        public override async Task<BookResponse> CreateAsync(BookCreateUpdateRequest request)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookException("User not authenticated.");
            }

            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
            
           
            request.CreatedByUserId = currentUserId.Value;
            
           
            BaseBookState baseState;
            if (isAdmin)
            {
                baseState = _baseBookState.GetBookState("Accepted");
            }
            else
            {
                baseState = _baseBookState.GetBookState("Submitted");
            }
            
            return await baseState.CreateAsync(request);
        }

        public override async Task<BookResponse?> UpdateAsync(int id, BookCreateUpdateRequest request)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookException("User not authenticated.");
            }

            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
            if (!isAdmin)
            {
                throw new BookException("Only admin can edit books.", true);
            }

            var baseState = _baseBookState.GetBookState(book.BookState);
            return await baseState.UpdateAsync(id, request);
        }

        public override async Task<BookResponse?> GetByIdAsync(int id)
        {
            var book = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.BookGenres)
                .ThenInclude(bg => bg.Genre)
                .Include(b => b.CreatedByUser)
                .FirstOrDefaultAsync(b => b.Id == id);

            if (book == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (currentUserId.HasValue)
            {
                var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
                if (!isAdmin && book.BookState != "Accepted")
                {
                    return null; 
                }
            }

            return MapToResponse(book);
        }

        public override async Task<PagedResult<BookResponse>> GetAsync(BookSearchObject search)
        {
            var query = _context.Set<Book>().AsQueryable();
            query = ApplyFilter(query, search);

           
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (currentUserId.HasValue)
            {
                var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
                if (!isAdmin)
                {
                    query = query.Where(b => b.BookState == "Accepted");
                }
            }
            else
            {
               
                query = query.Where(b => b.BookState == "Accepted");
            }

            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }

            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var list = await query.ToListAsync();
            return new PagedResult<BookResponse>
            {
                Items = list.Select(MapToResponse).ToList(),
                TotalCount = totalCount
            };
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                return false;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookException("User not authenticated.");
            }

            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
            if (!isAdmin)
            {
                throw new BookException("Only admin can delete books.", true);
            }

            await BeforeDelete(book);
            _context.Books.Remove(book);
            await _context.SaveChangesAsync();
            return true;
        }

      
        public async Task<BookResponse?> AcceptBookAsync(int id)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookException("User not authenticated.");
            }

            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
            if (!isAdmin)
            {
                throw new BookException("Only admin can accept books.", true);
            }

            var baseState = _baseBookState.GetBookState(book.BookState);
            return await baseState.AcceptAsync(id);
        }

        public async Task<BookResponse?> DeclineBookAsync(int id)
        {
            var book = await _context.Books.FindAsync(id);
            if (book == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookException("User not authenticated.");
            }

            var isAdmin = await _userRoleService.IsUserAdminAsync(currentUserId.Value);
            if (!isAdmin)
            {
                throw new BookException("Only admin can decline books.", true);
            }

            var baseState = _baseBookState.GetBookState(book.BookState);
            return await baseState.DeclineAsync(id);
        }

        protected override BookResponse MapToResponse(Book book)
        {
            return new BookResponse
            {
                Id = book.Id,
                Title = book.Title,
                AuthorId = book.AuthorId,
                AuthorName = book.Author?.Name ?? string.Empty,
                Description = book.Description,
                PublicationYear = book.PublicationYear,
                PageCount = book.PageCount,
                CoverImagePath = book.CoverImagePath,
                CreatedAt = book.CreatedAt,
                UpdatedAt = book.UpdatedAt,
                BookState = book.BookState,
                CreatedByUserId = book.CreatedByUserId,
                CreatedByUserName = book.CreatedByUser?.Username ?? string.Empty,
                Genres = book.BookGenres?.Select(bg => bg.Genre.Name).ToList() ?? new List<string>()
            };
        }
    }
} 