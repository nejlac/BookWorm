using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Requests
{
    public  class RoleCreateUpdateRequest
    {

        [Required(ErrorMessage = "Name is required.")]
        [MaxLength(50, ErrorMessage = "Name must not exceed 50 characters.")]
        public string Name { get; set; } = string.Empty;

        [MaxLength(200, ErrorMessage = "Description must not exceed 200 characters.")]
        public string Description { get; set; } = string.Empty;


        public bool IsActive { get; set; } = true;
    }
}
