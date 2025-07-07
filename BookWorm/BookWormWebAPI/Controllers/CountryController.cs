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
    [Authorize(Roles = "Admin,User")]
    public class CountryController : BaseCRUDController<CountryResponse, CountrySearchObject, CountryCreateUpdateRequest, CountryCreateUpdateRequest>
    {
        public CountryController(ICountryService countryService) : base(countryService)
        {
        }
    }
}
