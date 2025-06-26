using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IAuthorService
    {
        Task<List<AuthorResponse>> GetAsync(AuthorSearchObject search);
        Task<AuthorResponse?> GetByIdAsync(int id);
        Task<AuthorResponse> CreateAsync(AuthorCreateUpdateRequest request);
        Task<AuthorResponse?> UpdateAsync(int id, AuthorCreateUpdateRequest request);
        Task<bool> DeleteAsync(int id);
    }
} 