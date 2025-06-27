using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Requests
{
    public class UserCreateUpdateRequest : IValidatableObject
    {
        [Required(ErrorMessage = "First name is required.")]
        [MaxLength(50, ErrorMessage = "First name must not exceed 50 characters.")]
        public string FirstName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Last name is required.")]
        [MaxLength(50, ErrorMessage = "Last name must not exceed 50 characters.")]
        public string LastName { get; set; } = string.Empty;

        [Required(ErrorMessage = "Email is required.")]
        [MaxLength(100, ErrorMessage = "Email must not exceed 100 characters.")]
        [EmailAddress(ErrorMessage = "Invalid email format.")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Username is required.")]
        [MaxLength(100, ErrorMessage = "Username must not exceed 100 characters.")]
        public string Username { get; set; } = string.Empty;

        [MaxLength(20, ErrorMessage = "Phone number must not exceed 20 characters.")]
        [Phone(ErrorMessage = "Invalid phone number format.")]
        public string? PhoneNumber { get; set; }

        [Required(ErrorMessage = "Country is required.")]
        public int CountryId { get; set; }

        [Range(13, 100, ErrorMessage = "Age must be between 13 and 100.")]
        public int Age { get; set; }

        public bool IsActive { get; set; } = true;

        [Required(ErrorMessage = "Password is required.")]
        [MinLength(8, ErrorMessage = "Password must be at least 8 characters long.")]
        [RegularExpression(@"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$",
            ErrorMessage = "Password must contain uppercase, lowercase, number, and special character.")]
        public string? Password { get; set; }


        public List<int> RoleIds { get; set; } = new List<int>();

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {

            if (RoleIds == null || RoleIds.Count == 0)
            {
                yield return new ValidationResult("At least one role must be selected.", new[] { nameof(RoleIds) });
            }
        }
    }
}