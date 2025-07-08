using BookWorm.Model.Exceptions;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services.AuthorStateMachine
{
    public class InitialAuthorState:BaseAuthorState
    {
        public InitialAuthorState(IServiceProvider serviceProvider, BookWormDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {

        }
        public override async Task<AuthorResponse> CreateAsync(AuthorCreateUpdateRequest request)
        {
            if (await _context.Authors.AnyAsync(a =>
                a.Name.ToLower().Trim() == request.Name.ToLower().Trim() &&
                a.DateOfBirth.Date == request.DateOfBirth.Date))
            {
                throw new AuthorException($"An author with the name '{request.Name}' and date of birth '{request.DateOfBirth:yyyy-MM-dd}' already exists.");
            }
            var author = _mapper.Map<Author>(request);
            author.AuthorState = "Submitted";
            author.CreatedAt = DateTime.Now;
            author.UpdatedAt = DateTime.Now;
            _context.Authors.Add(author);
            await _context.SaveChangesAsync();
            return MapToResponse(author);
        }
    }
}
