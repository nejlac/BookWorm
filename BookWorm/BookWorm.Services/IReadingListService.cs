using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IReadingListService
    {
        Task<List<ReadingListResponse>> GetAsync(ReadingListSearchObject search);
        Task<ReadingListResponse?> GetByIdAsync(int id);
        Task<ReadingListResponse> CreateAsync(ReadingListCreateUpdateRequest request);
        Task<ReadingListResponse?> UpdateAsync(int id, ReadingListCreateUpdateRequest request);
        Task<ReadingListResponse> AddBookToListAsync(int readingListId, int bookId, DateTime? readAt = null);
        Task<bool> DeleteAsync(int id);
    }
} 