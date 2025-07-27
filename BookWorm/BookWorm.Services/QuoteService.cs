using BookWorm.Model.Exceptions;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class QuoteService : BaseCRUDService<QuoteResponse, QuoteSearchObject, Quote, QuoteCreateUpdateRequest, QuoteCreateUpdateRequest>, IQuoteService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<QuoteService> _logger;

        public QuoteService(BookWormDbContext context, IMapper mapper, ILogger<QuoteService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }

        protected override IQueryable<Quote> ApplyFilter(IQueryable<Quote> query, QuoteSearchObject search)
        {
            if (search.BookId.HasValue)
            {
                query = query.Where(q => q.BookId == search.BookId.Value);
            }
            if (search.UserId.HasValue)
            {
                query = query.Where(q => q.UserId == search.UserId.Value);
            }

            query = query.Include(q => q.User).Include(q => q.Book);
            return query;
        }

        protected override QuoteResponse MapToResponse(Quote entity)
        {
            return new QuoteResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                BookId = entity.BookId,
                QuoteText = entity.QuoteText ?? string.Empty
            };
        }

        protected override async Task BeforeInsert(Quote entity, QuoteCreateUpdateRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.QuoteText))
            {
                throw new QuoteException("Quote text cannot be empty.");
            }

            
            if (request.QuoteText.Length > 10000)
            {
                throw new QuoteException("Quote text cannot exceed 10,000 characters.");
            }

            _logger.LogInformation($"[QuoteService] Creating quote for user {request.UserId} and book {request.BookId}");
        }

        protected override async Task BeforeUpdate(Quote entity, QuoteCreateUpdateRequest request)
        {
          
            if (string.IsNullOrWhiteSpace(request.QuoteText))
            {
                throw new QuoteException("Quote text cannot be empty.");
            }

            if (request.QuoteText.Length > 10000)
            {
                throw new QuoteException("Quote text cannot exceed 10,000 characters.");
            }

            _logger.LogInformation($"[QuoteService] Updating quote {entity.Id} for user {request.UserId}");
        }

        public override async Task<QuoteResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.Quotes
                .Include(q => q.User)
                .Include(q => q.Book)
                .FirstOrDefaultAsync(q => q.Id == id);
            
            if (entity == null)
                return null;

            return MapToResponse(entity);
        }
    }
}
