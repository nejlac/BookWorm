using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BookWormWebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,User")]
    public class AuthorController : BaseCRUDController<AuthorResponse, AuthorSearchObject, AuthorCreateUpdateRequest, AuthorCreateUpdateRequest>
    {
        public AuthorController(IAuthorService authorService) : base(authorService)
        {
        }
    }
} 