using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IRoleService :ICRUDService<RoleResponse, RoleSearchObject, RoleCreateUpdateRequest, RoleCreateUpdateRequest>
    {

    }
}
