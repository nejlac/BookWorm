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
    public class BookClubEventService : BaseCRUDService<BookClubEventResponse, BookClubEventSearchObject, BookClubEvent, BookClubEventCreateUpdateRequest, BookClubEventCreateUpdateRequest>, IBookClubEventService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<BookClubEventService> _logger;
        private readonly IUserRoleService _userRoleService;
        private readonly IBookClubService _bookClubService;

        public BookClubEventService(BookWormDbContext context, IMapper mapper, ILogger<BookClubEventService> logger, IUserRoleService userRoleService, IBookClubService bookClubService) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
            _userRoleService = userRoleService;
            _bookClubService = bookClubService;
        }

        protected override IQueryable<BookClubEvent> ApplyFilter(IQueryable<BookClubEvent> query, BookClubEventSearchObject search)
        {
            if (!string.IsNullOrEmpty(search.Title))
                query = query.Where(bce => bce.Title.Contains(search.Title));
            if (search.BookClubId.HasValue)
                query = query.Where(bce => bce.BookClubId == search.BookClubId.Value);
            if (search.BookId.HasValue)
                query = query.Where(bce => bce.BookId == search.BookId.Value);
            if (search.CreatorId.HasValue)
                query = query.Where(bce => bce.CreatorId == search.CreatorId.Value);

            query = query.Include(bce => bce.Book)
                        .ThenInclude(b => b.Author)
                        .Include(bce => bce.BookClub)
                        .Include(bce => bce.Creator)
                        .Include(bce => bce.Participants);
            return query;
        }

        public override async Task<BookClubEventResponse> CreateAsync(BookClubEventCreateUpdateRequest request)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubEventException("User not authenticated.");
            }

            // Verify the book exists
            var book = await _context.Books.FindAsync(request.BookId);
            if (book == null)
            {
                throw new BookClubEventException("Book not found.", true);
            }

            // Get the book club to verify the user is the creator
            var bookClub = await _context.BookClubs
                .Include(bc => bc.Members)
                .FirstOrDefaultAsync(bc => bc.Id == request.BookClubId);

            if (bookClub == null)
            {
                throw new BookClubEventException("Book club not found.", true);
            }

            if (bookClub.CreatorId != currentUserId.Value)
            {
                throw new BookClubEventException("Only the book club creator can create events.", true);
            }

            // Check if the book is already used in another event in this book club
            var existingEventWithSameBook = await _context.BookClubEvents
                .FirstOrDefaultAsync(bce => bce.BookClubId == request.BookClubId && bce.BookId == request.BookId);

            if (existingEventWithSameBook != null)
            {
                throw new BookClubEventException("This book is already used in another event in this book club.", true);
            }

            var bookClubEvent = new BookClubEvent
            {
                Title = request.Title,
                Description = request.Description,
                Deadline = request.Deadline,
                BookId = request.BookId,
                BookClubId = request.BookClubId,
                CreatorId = currentUserId.Value
            };

            _context.BookClubEvents.Add(bookClubEvent);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(bookClubEvent.Id);
        }

        public override async Task<BookClubEventResponse?> UpdateAsync(int id, BookClubEventCreateUpdateRequest request)
        {
            var bookClubEvent = await _context.BookClubEvents.FindAsync(id);
            if (bookClubEvent == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubEventException("User not authenticated.");
            }

            if (bookClubEvent.CreatorId != currentUserId.Value)
            {
                throw new BookClubEventException("Only the event creator can edit the event.", true);
            }

            // Verify the book exists
            var book = await _context.Books.FindAsync(request.BookId);
            if (book == null)
            {
                throw new BookClubEventException("Book not found.", true);
            }

            // Check if the book is already used in another event in this book club (excluding current event)
            var existingEventWithSameBook = await _context.BookClubEvents
                .FirstOrDefaultAsync(bce => bce.BookClubId == bookClubEvent.BookClubId && 
                                          bce.BookId == request.BookId && 
                                          bce.Id != id);

            if (existingEventWithSameBook != null)
            {
                throw new BookClubEventException("This book is already used in another event in this book club.", true);
            }

            bookClubEvent.Title = request.Title;
            bookClubEvent.Description = request.Description;
            bookClubEvent.Deadline = request.Deadline;
            bookClubEvent.BookId = request.BookId;

            await _context.SaveChangesAsync();
            return await GetByIdAsync(id);
        }

        public override async Task<BookClubEventResponse?> GetByIdAsync(int id)
        {
            var bookClubEvent = await _context.BookClubEvents
                .Include(bce => bce.Book)
                .ThenInclude(b => b.Author)
                .Include(bce => bce.BookClub)
                .Include(bce => bce.Creator)
                .Include(bce => bce.Participants)
                .FirstOrDefaultAsync(bce => bce.Id == id);

            if (bookClubEvent == null)
                return null;

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            var isParticipant = currentUserId.HasValue && await IsParticipantAsync(id, currentUserId.Value);
            var isCreator = currentUserId.HasValue && await IsCreatorAsync(id, currentUserId.Value);
            var isCompleted = currentUserId.HasValue && isParticipant && 
                bookClubEvent.Participants.Any(p => p.UserId == currentUserId.Value && p.IsCompleted);

            return MapToResponse(bookClubEvent, isParticipant, isCompleted, isCreator);
        }

        public override async Task<PagedResult<BookClubEventResponse>> GetAsync(BookClubEventSearchObject search)
        {
            var query = _context.Set<BookClubEvent>().AsQueryable();
            query = ApplyFilter(query, search);

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();

            if (search.IsParticipant.HasValue && search.IsParticipant.Value && currentUserId.HasValue)
            {
                query = query.Where(bce => bce.Participants.Any(p => p.UserId == currentUserId.Value));
            }

            if (search.IsCreator.HasValue && search.IsCreator.Value && currentUserId.HasValue)
            {
                query = query.Where(bce => bce.CreatorId == currentUserId.Value);
            }

            if (search.IsCompleted.HasValue && search.IsCompleted.Value && currentUserId.HasValue)
            {
                query = query.Where(bce => bce.Participants.Any(p => p.UserId == currentUserId.Value && p.IsCompleted));
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
            var responses = new List<BookClubEventResponse>();

            foreach (var bookClubEvent in list)
            {
                var isParticipant = currentUserId.HasValue && await IsParticipantAsync(bookClubEvent.Id, currentUserId.Value);
                var isCreator = currentUserId.HasValue && await IsCreatorAsync(bookClubEvent.Id, currentUserId.Value);
                var isCompleted = currentUserId.HasValue && isParticipant && 
                    bookClubEvent.Participants.Any(p => p.UserId == currentUserId.Value && p.IsCompleted);
                responses.Add(MapToResponse(bookClubEvent, isParticipant, isCompleted, isCreator));
            }

            return new PagedResult<BookClubEventResponse>
            {
                Items = responses,
                TotalCount = totalCount
            };
        }

        public async Task<bool> ParticipateInEventAsync(ParticipateInEventRequest request)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubEventException("User not authenticated.");
            }

            var bookClubEvent = await _context.BookClubEvents
                .Include(bce => bce.BookClub)
                .FirstOrDefaultAsync(bce => bce.Id == request.BookClubEventId);

            if (bookClubEvent == null)
            {
                throw new BookClubEventException("Event not found.", true);
            }

            // Check if user is a member of the book club
            var isMember = await _bookClubService.IsMemberAsync(bookClubEvent.BookClubId, currentUserId.Value);
            if (!isMember)
            {
                throw new BookClubEventException("You must be a member of the book club to participate in events.", true);
            }

            var existingParticipant = await _context.BookClubEventParticipants
                .FirstOrDefaultAsync(bcep => bcep.UserId == currentUserId.Value && bcep.BookClubEventId == request.BookClubEventId);

            if (existingParticipant != null)
            {
                throw new BookClubEventException("You are already participating in this event.", true);
            }

            var participant = new BookClubEventParticipant
            {
                UserId = currentUserId.Value,
                BookClubEventId = request.BookClubEventId,
                IsCompleted = false
            };

            _context.BookClubEventParticipants.Add(participant);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> LeaveEventAsync(int eventId)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubEventException("User not authenticated.");
            }

            var participant = await _context.BookClubEventParticipants
                .FirstOrDefaultAsync(bcep => bcep.UserId == currentUserId.Value && bcep.BookClubEventId == eventId);

            if (participant == null)
            {
                throw new BookClubEventException("You are not participating in this event.", true);
            }

            _context.BookClubEventParticipants.Remove(participant);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> MarkEventAsCompletedAsync(int eventId)
        {
            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            if (!currentUserId.HasValue)
            {
                throw new BookClubEventException("User not authenticated.");
            }

            var participant = await _context.BookClubEventParticipants
                .FirstOrDefaultAsync(bcep => bcep.UserId == currentUserId.Value && bcep.BookClubEventId == eventId);

            if (participant == null)
            {
                throw new BookClubEventException("You are not participating in this event.", true);
            }

            participant.IsCompleted = true;
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> IsParticipantAsync(int eventId, int userId)
        {
            return await _context.BookClubEventParticipants
                .AnyAsync(bcep => bcep.BookClubEventId == eventId && bcep.UserId == userId);
        }

        public async Task<bool> IsCreatorAsync(int eventId, int userId)
        {
            return await _context.BookClubEvents
                .AnyAsync(bce => bce.Id == eventId && bce.CreatorId == userId);
        }

        public async Task<List<BookClubEventResponse>> GetEventsByBookClubAsync(int bookClubId)
        {
            var events = await _context.BookClubEvents
                .Include(bce => bce.Book)
                .ThenInclude(b => b.Author)
                .Include(bce => bce.BookClub)
                .Include(bce => bce.Creator)
                .Include(bce => bce.Participants)
                .Where(bce => bce.BookClubId == bookClubId)
                .OrderByDescending(bce => bce.Deadline)
                .ToListAsync();

            var currentUserId = await _userRoleService.GetCurrentUserIdAsync();
            var responses = new List<BookClubEventResponse>();

            foreach (var bookClubEvent in events)
            {
                var isParticipant = currentUserId.HasValue && await IsParticipantAsync(bookClubEvent.Id, currentUserId.Value);
                var isCreator = currentUserId.HasValue && await IsCreatorAsync(bookClubEvent.Id, currentUserId.Value);
                var isCompleted = currentUserId.HasValue && isParticipant && 
                    bookClubEvent.Participants.Any(p => p.UserId == currentUserId.Value && p.IsCompleted);
                responses.Add(MapToResponse(bookClubEvent, isParticipant, isCompleted, isCreator));
            }

            return responses;
        }

        protected override BookClubEventResponse MapToResponse(BookClubEvent bookClubEvent)
        {
            return MapToResponse(bookClubEvent, false, false, false);
        }

        private BookClubEventResponse MapToResponse(BookClubEvent bookClubEvent, bool isParticipant, bool isCompleted, bool isCreator)
        {
            return new BookClubEventResponse
            {
                Id = bookClubEvent.Id,
                Title = bookClubEvent.Title,
                Description = bookClubEvent.Description,
                Deadline = bookClubEvent.Deadline,
                BookId = bookClubEvent.BookId,
                BookTitle = bookClubEvent.Book?.Title ?? string.Empty,
                BookAuthorName = bookClubEvent.Book?.Author?.Name ?? string.Empty,
                BookCoverImagePath = bookClubEvent.Book?.CoverImagePath ?? string.Empty,
                BookClubId = bookClubEvent.BookClubId,
                BookClubName = bookClubEvent.BookClub?.Name ?? string.Empty,
                CreatorId = bookClubEvent.CreatorId,
                CreatorName = bookClubEvent.Creator?.Username ?? string.Empty,
                ParticipantsCount = bookClubEvent.Participants?.Count ?? 0,
                CompletedParticipantsCount = bookClubEvent.Participants?.Count(p => p.IsCompleted) ?? 0,
                IsParticipant = isParticipant,
                IsCompleted = isCompleted,
                IsCreator = isCreator
            };
        }
    }
} 