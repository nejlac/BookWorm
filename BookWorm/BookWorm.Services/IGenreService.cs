using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;

namespace BookWorm.Services
{
    public interface IGenreService : ICRUDService<GenreResponse, GenreSearchObject, GenreCreateUpdateRequest, GenreCreateUpdateRequest>
    {
    }
} 