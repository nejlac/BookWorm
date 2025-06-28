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
    [Authorize(Roles = "Admin,User")]
    [Route("api/[controller]")]
    public class BookReviewController : BaseCRUDController<BookReviewResponse, BookReviewSearchObject, BookReviewCreateUpdateRequest, BookReviewCreateUpdateRequest>
    {
        public BookReviewController(IBookReviewService bookReviewService) : base(bookReviewService)
        {
        }
    }
} 