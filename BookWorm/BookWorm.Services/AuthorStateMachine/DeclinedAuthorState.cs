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
    public class DeclinedAuthorState:BaseAuthorState
    {
        public DeclinedAuthorState(IServiceProvider serviceProvider, BookWormDbContext context, IMapper mapper) : base(serviceProvider, context, mapper)
        {
        }
        public override async Task<AuthorResponse> AcceptAsync(int id)
        {
            var author = await _context.Authors.Include(a => a.Country).Include(a => a.Books).FirstOrDefaultAsync(a => a.Id == id);
            if (author == null)
                throw new AuthorException("Author not found.");
            author.AuthorState = "Accepted";
            author.UpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();
            return MapToResponse(author);
        }
        public override async Task<AuthorResponse> UpdateAsync(int id, AuthorCreateUpdateRequest request)
        {

            if (await _context.Authors.AnyAsync(a =>
                a.Id != id &&
                a.Name.ToLower().Trim() == request.Name.ToLower().Trim() &&
                a.DateOfBirth.Date == request.DateOfBirth.Date))
            {
                throw new AuthorException($"An author with the name '{request.Name}' and date of birth '{request.DateOfBirth:yyyy-MM-dd}' already exists.");
            }
            throw new AuthorException("Cannot update author in Submitted state. Only admin can update after acceptance.");
        }
    }
}
