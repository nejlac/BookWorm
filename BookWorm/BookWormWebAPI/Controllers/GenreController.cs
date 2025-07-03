using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class GenreController : BaseCRUDController<GenreResponse, GenreSearchObject, GenreCreateUpdateRequest, GenreCreateUpdateRequest>
    {
        public GenreController(IGenreService genreService) : base(genreService)
        {
        }
    }
} 