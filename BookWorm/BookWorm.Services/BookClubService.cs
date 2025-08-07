using BookWorm.Model.Exceptions;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace BookWorm.Services
{
    public class BookClubService : BaseCRUDService<BookClubResponse, BookClubSearchObject, BookClub, BookClubCreateUpdateRequest, BookClubCreateUpdateRequest>, IBookClubService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<BookClubService> _logger;
        private readonly IUserRoleService _userRoleService;

        public BookClubService(BookWormDbContext context, IMapper mapper, ILogger<BookClubService> logger, IUserRoleService userRoleService) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _userRoleService = userRoleService;
        }

        protected override IQueryable<BookClub> ApplyFilter(IQueryable<BookClub> query, BookClubSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Name))
                query = query.Where(bc => bc.Name.Contains(search.Name));
            if (!string.IsNullOrEmpty(search.CreatorName))
                query = query.Where(bc => bc.ClubCreator.Username.Contains(search.CreatorName));
            if (search.CreatorId.HasValue)
                query = query.Where(bc => bc.CreatorId == search.CreatorId.Value);

            query = query.Include(bc => bc.ClubCreator)
                        .Include(bc => bc.Members)
                        .Include(bc => bc.Events);
            return query;
        }

        public override async Task<BookClubResponse> CreateAsync(BookClubCreateUpdateRequest request)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubException("User not authenticated.");
            }

            // Check if a book club with the same name already exists
            var existingBookClub = await _context.BookClubs
                .FirstOrDefaultAsync(bc => bc.Name.ToLower() == request.Name.ToLower());

            if (existingBookClub != null)
            {
                throw new BookClubException("A book club with this name already exists.", true);
            }

            var bookClub = new BookClub
            {
                Name = request.Name,
                Description = request.Description,
                CreatorId = currentUserId.Value,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.BookClubs.Add(bookClub);
            await _context.SaveChangesAsync();

            // Add creator as first member
            var member = new BookClubMember
            {
                UserId = currentUserId.Value,
                BookClubId = bookClub.Id,
                JoinedAt = DateTime.UtcNow
            };

            _context.BookClubMembers.Add(member);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(bookClub.Id);
        }

        public override async Task<BookClubResponse?> UpdateAsync(int id, BookClubCreateUpdateRequest request)
        {
            var bookClub = await _context.BookClubs.FindAsync(id);
            if (bookClub == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubException("User not authenticated.");
            }

            if (bookClub.CreatorId != currentUserId.Value)
            {
                throw new BookClubException("Only the creator can edit the book club.", true);
            }

            // Check if a book club with the same name already exists (excluding current book club)
            var existingBookClub = await _context.BookClubs
                .FirstOrDefaultAsync(bc => bc.Name.ToLower() == request.Name.ToLower() && bc.Id != id);

            if (existingBookClub != null)
            {
                throw new BookClubException("A book club with this name already exists.", true);
            }

            bookClub.Name = request.Name;
            bookClub.Description = request.Description;
            bookClub.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return await GetByIdAsync(id);
        }

        public override async Task<BookClubResponse?> GetByIdAsync(int id)
        {
            var bookClub = await _context.BookClubs
                .Include(bc => bc.ClubCreator)
                .Include(bc => bc.Members)
                .Include(bc => bc.Events)
                .FirstOrDefaultAsync(bc => bc.Id == id);

            if (bookClub == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            var isMember = currentUserId.HasValue && await IsMemberAsync(id, currentUserId.Value);
            var isCreator = currentUserId.HasValue && await IsCreatorAsync(id, currentUserId.Value);

            return MapToResponse(bookClub, isMember, isCreator);
        }

        public override async Task<PagedResult<BookClubResponse>> GetAsync(BookClubSearchObject search)
        {
            var query = _context.Set<BookClub>().AsQueryable();
            query = ApplyFilter(query, search);

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();

            if (search.IsMember.HasValue && search.IsMember.Value && currentUserId.HasValue)
            {
                query = query.Where(bc => bc.Members.Any(m => m.UserId == currentUserId.Value));
            }

            if (search.IsCreator.HasValue && search.IsCreator.Value && currentUserId.HasValue)
            {
                query = query.Where(bc => bc.CreatorId == currentUserId.Value);
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
            var responses = new List<BookClubResponse>();

            foreach (var bookClub in list)
            {
                var isMember = currentUserId.HasValue && await IsMemberAsync(bookClub.Id, currentUserId.Value);
                var isCreator = currentUserId.HasValue && await IsCreatorAsync(bookClub.Id, currentUserId.Value);
                responses.Add(MapToResponse(bookClub, isMember, isCreator));
            }

            return new PagedResult<BookClubResponse>
            {
                Items = responses,
                TotalCount = totalCount
            };
        }

        public async Task<bool> JoinBookClubAsync(JoinBookClubRequest request)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubException("User not authenticated.");
            }

            var bookClub = await _context.BookClubs.FindAsync(request.BookClubId);
            if (bookClub == null)
            {
                throw new BookClubException("Book club not found.", true);
            }

            var existingMember = await _context.BookClubMembers
                .FirstOrDefaultAsync(bcm => bcm.UserId == currentUserId.Value && bcm.BookClubId == request.BookClubId);

            if (existingMember != null)
            {
                throw new BookClubException("You are already a member of this book club.", true);
            }

            var member = new BookClubMember
            {
                UserId = currentUserId.Value,
                BookClubId = request.BookClubId,
                JoinedAt = DateTime.UtcNow
            };

            _context.BookClubMembers.Add(member);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> LeaveBookClubAsync(int bookClubId)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubException("User not authenticated.");
            }

            var member = await _context.BookClubMembers
                .FirstOrDefaultAsync(bcm => bcm.UserId == currentUserId.Value && bcm.BookClubId == bookClubId);

            if (member == null)
            {
                throw new BookClubException("You are not a member of this book club.", true);
            }

            var bookClub = await _context.BookClubs.FindAsync(bookClubId);
            if (bookClub?.CreatorId == currentUserId.Value)
            {
                throw new BookClubException("The creator cannot leave the book club. Transfer ownership or delete the club instead.", true);
            }

            _context.BookClubMembers.Remove(member);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<List<BookClubMemberResponse>> GetBookClubMembersAsync(int bookClubId)
        {
            var members = await _context.BookClubMembers
                .Include(bcm => bcm.User)
                .Where(bcm => bcm.BookClubId == bookClubId)
                .OrderBy(bcm => bcm.JoinedAt)
                .ToListAsync();

            return members.Select(m => new BookClubMemberResponse
            {
                Id = m.Id,
                UserId = m.UserId,
                UserName = m.User.Username,
                UserEmail = m.User.Email,
                JoinedAt = m.JoinedAt
            }).ToList();
        }

        public async Task<bool> IsMemberAsync(int bookClubId, int userId)
        {
            return await _context.BookClubMembers
                .AnyAsync(bcm => bcm.BookClubId == bookClubId && bcm.UserId == userId);
        }

        public async Task<bool> IsCreatorAsync(int bookClubId, int userId)
        {
            return await _context.BookClubs
                .AnyAsync(bc => bc.Id == bookClubId && bc.CreatorId == userId);
        }

        protected override BookClubResponse MapToResponse(BookClub bookClub)
        {
            return MapToResponse(bookClub, false, false);
        }

        private BookClubResponse MapToResponse(BookClub bookClub, bool isMember, bool isCreator)
        {
            return new BookClubResponse
            {
                Id = bookClub.Id,
                Name = bookClub.Name,
                Description = bookClub.Description,
                CreatorId = bookClub.CreatorId,
                CreatorName = bookClub.ClubCreator?.Username ?? string.Empty,
                CreatedAt = bookClub.CreatedAt,
                UpdatedAt = bookClub.UpdatedAt,
                MembersCount = bookClub.Members?.Count ?? 0,
                EventsCount = bookClub.Events?.Count ?? 0,
                IsMember = isMember,
                IsCreator = isCreator
            };
        }
    }
} 