using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class RoleService : BaseCRUDService<RoleResponse, RoleSearchObject, Role, RoleCreateUpdateRequest, RoleCreateUpdateRequest>, IRoleService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<RoleService> _logger;

        public RoleService(BookWormDbContext context, IMapper mapper, ILogger<RoleService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }
      

    }
}
