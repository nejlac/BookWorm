using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IBookService : ICRUDService<BookResponse, BookSearchObject, BookCreateUpdateRequest, BookCreateUpdateRequest>
    {
       
        Task<BookResponse?> AcceptBookAsync(int id);
        Task<BookResponse?> DeclineBookAsync(int id);
        Task<List<MostReadBookResponse?>> GetMostReadBooks(int id);
        Task<int> GetBooksCount();
        Task<List<GenreStatisticResponse>>GetMostReadGenres(int id);
        Task<BookRatingResponse?> GetBookRatingAsync(int bookId);
        Task<List<BookResponse>> GetRecommendedBooksAsync(int userId);
    }
} 