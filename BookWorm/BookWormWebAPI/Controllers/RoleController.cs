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
    public class RoleController : BaseCRUDController<RoleResponse, RoleSearchObject, RoleCreateUpdateRequest, RoleCreateUpdateRequest>
    {
        public RoleController(IRoleService roleService) : base(roleService)
        {
        }
    }
}
