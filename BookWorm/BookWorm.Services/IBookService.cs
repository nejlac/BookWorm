using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IBookService
    {
        Task<List<BookResponse>> GetAsync(BookSearchObject search);
        Task<BookResponse?> GetByIdAsync(int id);
        Task<BookResponse> CreateAsync(BookCreateUpdateRequest request);
        Task<BookResponse?> UpdateAsync(int id, BookCreateUpdateRequest request);
        Task<bool> DeleteAsync(int id);
    }
} 