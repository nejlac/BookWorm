using BookWorm.Model.Exceptions;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Services.BookStateMachine;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services.AuthorStateMachine
{
    public class BaseAuthorState
    {

        protected readonly IServiceProvider _serviceProvider;
        protected readonly BookWormDbContext _context;
        protected readonly IMapper _mapper;

        public BaseAuthorState(IServiceProvider serviceProvider, BookWormDbContext context, IMapper mapper)
        {
            _serviceProvider = serviceProvider;
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<AuthorResponse> CreateAsync(AuthorCreateUpdateRequest request)
        {
            throw new AuthorException("Not allowed");
        }

        public virtual async Task<AuthorResponse> UpdateAsync(int id, AuthorCreateUpdateRequest request)
        {
            throw new AuthorException("Not allowed");
        }

        public virtual async Task<AuthorResponse> AcceptAsync(int id)
        {
            throw new AuthorException("Not allowed")
            {

            };
        }

        public virtual async Task<AuthorResponse> DeclineAsync(int id)
        {
            throw new AuthorException("Not allowed");
        }

        public BaseAuthorState GetAuthorState(string stateName)
        {
            switch (stateName)
            {
                case "Submitted":
                    return _serviceProvider.GetService<SubmittedAuthorState>();
                case "Accepted":
                    return _serviceProvider.GetService<AcceptedAuthorState>();
                case "Declined":
                    return _serviceProvider.GetService<DeclinedAuthorState>();

                default:
                    throw new Exception($"State {stateName} not defined");
            }
        }

        

        

        protected AuthorResponse MapToResponse(Author author)
        {
            return new AuthorResponse
            {
                Id = author.Id,
                Name = author.Name,
                Biography = author.Biography ?? string.Empty,
                DateOfBirth = author.DateOfBirth,
                DateOfDeath = author.DateOfDeath,
                CountryId = author.CountryId,
                CountryName = author.Country?.Name ?? string.Empty,
                PhotoUrl = author.PhotoUrl ?? string.Empty,
                CreatedAt = author.CreatedAt,
                UpdatedAt = author.UpdatedAt,
                Books = author.Books.Select(b => new AuthorBookResponse
                {
                    Id = b.Id,
                    Title = b.Title,
                    PublicationYear = b.PublicationYear,
                    PageCount = b.PageCount
                }).ToList(),


                AuthorState = author.AuthorState,
                CreatedByUserId = author.CreatedByUserId,
                CreatedByUserName = author.CreatedByUser?.Username ?? string.Empty

            };
        }
    
}
}
