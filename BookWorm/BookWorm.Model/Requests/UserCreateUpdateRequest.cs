using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Requests
{
    public  class UserCreateUpdateRequest
    {
        [Required]
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string Username { get; set; } = string.Empty;

        
        [MaxLength(20)]
        [Phone]
        public string? PhoneNumber { get; set; }
        public int CountryId { get; set; }
        public int Age { get; set; }   

        public bool IsActive { get; set; } = true;


        
        [MinLength(8)]
        [RegularExpression(@"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$", ErrorMessage = "Password must be at least 8 characters and contain uppercase, lowercase, number, and special character.")]
        public string? Password { get; set; }


        public List<int> RoleIds { get; set; } = new List<int>();
    }
}
