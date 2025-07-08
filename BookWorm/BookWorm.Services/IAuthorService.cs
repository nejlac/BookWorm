using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IAuthorService: ICRUDService<AuthorResponse, AuthorSearchObject, AuthorCreateUpdateRequest, AuthorCreateUpdateRequest>
    {
        Task<AuthorResponse?> AcceptAuthorAsync(int id);
        Task<AuthorResponse?> DeclineAuthorAsync(int id);
    }
} 