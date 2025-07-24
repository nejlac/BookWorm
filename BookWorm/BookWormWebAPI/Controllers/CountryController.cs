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
    [AllowAnonymous]
    public class CountryController : BaseCRUDController<CountryResponse, CountrySearchObject, CountryCreateUpdateRequest, CountryCreateUpdateRequest>
    {
        public CountryController(ICountryService countryService) : base(countryService)
        {
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<CountryResponse>> Get([FromQuery] CountrySearchObject search = null)
        {
            if (search == null)
                search = new CountrySearchObject();
            if (!search.PageSize.HasValue || search.PageSize.Value == 0)
                search.PageSize = 500; 
            return await base.Get(search);
        }
    }
}
