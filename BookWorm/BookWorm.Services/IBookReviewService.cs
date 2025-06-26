using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IBookReviewService
    {
        Task<List<BookReviewResponse>> GetAsync(BookReviewSearchObject search);
        Task<BookReviewResponse?> GetByIdAsync(int id);
        Task<BookReviewResponse> CreateAsync(BookReviewCreateUpdateRequest request);
        Task<BookReviewResponse?> UpdateAsync(int id, BookReviewCreateUpdateRequest request);
        Task<bool> DeleteAsync(int id);
    }
} 