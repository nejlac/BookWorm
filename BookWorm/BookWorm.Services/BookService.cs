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
            if (search.AuthorId.HasValue)
                query = query.Where(b => b.AuthorId == search.AuthorId.Value);
            if (search.GenreId.HasValue)
                query = query.Where(b => b.BookGenres.Any(bg => bg.GenreId == search.GenreId));
            if (search.PublicationYear.HasValue)
                query = query.Where(b => b.PublicationYear == search.PublicationYear);
            if (search.PageCount.HasValue)
                query = query.Where(b => b.PageCount == search.PageCount);
            if (search.MinPageCount.HasValue)
                query = query.Where(b => b.PageCount >= search.MinPageCount.Value);
            if (search.MaxPageCount.HasValue)
                query = query.Where(b => b.PageCount <= search.MaxPageCount.Value);
            if (!string.IsNullOrEmpty(search.FTS))
                query = query.Where(b => b.Title.Contains(search.FTS) || b.Description.Contains(search.FTS) || b.Author.Name.Contains(search.FTS));
            if (!string.IsNullOrEmpty(search.Status))
                query = query.Where(b => b.BookState == search.Status);

           
            if (!string.IsNullOrEmpty(search.SortBy))
            {
                switch (search.SortBy.ToLower())
                {
                    case "title_asc":
                        query = query.OrderBy(b => b.Title);
                        break;
                    case "title_desc":
                        query = query.OrderByDescending(b => b.Title);
                        break;
                    case "year_asc":
                        query = query.OrderBy(b => b.PublicationYear);
                        break;
                    case "year_desc":
                        query = query.OrderByDescending(b => b.PublicationYear);
                        break;
                    case "rating_asc":
                        query = query.OrderBy(b => b.BookReviews.Average(br => br.Rating));
                        break;
                    case "rating_desc":
                        query = query.OrderByDescending(b => b.BookReviews.Average(br => br.Rating));
                        break;
                }
            }

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
                if (!isAdmin && book.BookState != "Accepted" && book.CreatedByUserId != currentUserId.Value)
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
                    query = query.Where(b => b.BookState == "Accepted" || b.CreatedByUserId == currentUserId.Value);
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

            // 1. Delete all BookReviews for this book
            var reviews = _context.BookReviews.Where(r => r.BookId == id);
            _context.BookReviews.RemoveRange(reviews);

            // 2. Delete all BookGenres for this book
            var bookGenres = _context.BookGenres.Where(bg => bg.BookId == id);
            _context.BookGenres.RemoveRange(bookGenres);

            // 3. Delete all ReadingListBooks for this book
            var readingListBooks = _context.ReadingListBooks.Where(rlb => rlb.BookId == id);
            _context.ReadingListBooks.RemoveRange(readingListBooks);

            // 4. Delete all ReadingChallengeBooks for this book
            var challengeBooks = _context.ReadingChallengeBooks.Where(rcb => rcb.BookId == id);
            _context.ReadingChallengeBooks.RemoveRange(challengeBooks);

            var quoteBooks = _context.Quotes.Where(q => q.BookId == id);
            _context.Quotes.RemoveRange(quoteBooks);

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

        // --- STATISTICS METHODS ---
        public async Task<List<MostReadBookResponse>> GetMostReadBooks(int topN = 4)
        {
            // Rank by number of unique users who have the book in their Read lists
            var readListBooks = await _context.ReadingListBooks
                .Include(rlb => rlb.ReadingList)
                .Where(rlb => rlb.ReadingList.Name == "Read")
                .ToListAsync();

            var bookUserCounts = readListBooks
                .GroupBy(rlb => rlb.BookId)
                .Select(g => new { BookId = g.Key, UserCount = g.Select(x => x.ReadingList.UserId).Distinct().Count() })
                .ToDictionary(x => x.BookId, x => x.UserCount);

            var books = await _context.Books
                .Include(b => b.Author)
                .Include(b => b.BookReviews)
                .ToListAsync();

            var rankedBooks = books
                .Select(b => new
                {
                    Book = b,
                    UserCount = bookUserCounts.ContainsKey(b.Id) ? bookUserCounts[b.Id] : 0,
                    RatingsCount = b.BookReviews.Count
                })
                .OrderByDescending(x => x.UserCount)
                .ThenByDescending(x => x.RatingsCount)
                .Take(topN)
                .Select(x => new MostReadBookResponse
                {
                    BookId = x.Book.Id,
                    Title = x.Book.Title,
                    AuthorName = x.Book.Author.Name,
                    CoverImageUrl = x.Book.CoverImagePath,
                    AverageRating = x.Book.BookReviews.Any() ? x.Book.BookReviews.Average(r => r.Rating) : 0,
                    RatingsCount = x.RatingsCount
                })
                .ToList();
            return rankedBooks;
        }

        public async Task<int> GetBooksCount()
        {
            return await _context.Books.CountAsync();
        }

        public async Task<List<GenreStatisticResponse>> GetMostReadGenres(int topN = 3)
        {
            // Rank genres by the number of unique users who have any book in that genre in their Read lists
            var readListBooks = await _context.ReadingListBooks
                .Include(rlb => rlb.ReadingList)
                .Where(rlb => rlb.ReadingList.Name == "Read")
                .ToListAsync();

            var bookGenrePairs = await _context.BookGenres
                .Include(bg => bg.Genre)
                .ToListAsync();

            var genreUserCounts = bookGenrePairs
                .GroupBy(bg => bg.Genre.Name)
                .Select(g => new
                {
                    GenreName = g.Key,
                    UserCount = readListBooks
                        .Where(rlb => g.Select(bg => bg.BookId).Contains(rlb.BookId))
                        .Select(rlb => rlb.ReadingList.UserId)
                        .Distinct()
                        .Count()
                })
                .OrderByDescending(g => g.UserCount)
                .Take(topN)
                .ToList();

            var totalUsers = genreUserCounts.Sum(g => g.UserCount);
            if (totalUsers == 0)
            {
                var allGenres = await _context.Genres.ToListAsync();
                return allGenres.Select(g => new GenreStatisticResponse
                {
                    GenreName = g.Name,
                    Percentage = 0
                }).ToList();
            }

            return genreUserCounts.Select(g => new GenreStatisticResponse
            {
                GenreName = g.GenreName,
                Percentage = (double)g.UserCount * 100 / totalUsers
            }).ToList();
        }

        public async Task<BookRatingResponse?> GetBookRatingAsync(int bookId)
        {
            var book = await _context.Books
                .Where(b => b.Id == bookId && b.BookState == "Accepted")
                .FirstOrDefaultAsync();

            if (book == null)
                return null;

            var ratingStats = await _context.BookReviews
                .Where(br => br.BookId == bookId)
                .GroupBy(br => br.BookId)
                .Select(g => new
                {
                    AverageRating = g.Average(br => br.Rating),
                    RatingCount = g.Count()
                })
                .FirstOrDefaultAsync();

            if (ratingStats == null)
            {
                return new BookRatingResponse
                {
                    BookId = bookId,
                    BookTitle = book.Title,
                    AverageRating = 0,
                    RatingCount = 0
                };
            }

            return new BookRatingResponse
            {
                BookId = bookId,
                BookTitle = book.Title,
                AverageRating = Math.Round(ratingStats.AverageRating, 1),
                RatingCount = ratingStats.RatingCount
            };
        }
    }

    } 