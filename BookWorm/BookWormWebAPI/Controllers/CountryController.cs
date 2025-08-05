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
        private readonly ICountryService _countryService;

        public CountryController(ICountryService countryService) : base(countryService)
        {
            _countryService = countryService;
        }

        [HttpGet]
        [AllowAnonymous]
        public override async Task<PagedResult<CountryResponse>> Get([FromQuery] CountrySearchObject search = null)
        {
            if (search == null)
                search = new CountrySearchObject();
            return await base.Get(search);
        }

        [HttpDelete("{id}")]
        public override async Task<bool> Delete(int id)
        {
            try
            {
                return await _countryService.DeleteAsync(id);
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }
    }
}
