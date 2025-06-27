using System;
using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class AuthorCreateUpdateRequest: IValidatableObject
    {
        [Required(ErrorMessage = "Name is required.")]
        [MaxLength(255, ErrorMessage = "Name must not exceed 255 characters.")]
        public string Name { get; set; } = string.Empty;

        [Required(ErrorMessage = "Biography is required.")]
        [MaxLength(1000, ErrorMessage = "Biography must not exceed 1000 characters.")]
        public string Biography { get; set; } = string.Empty;

        [Required(ErrorMessage = "Date of birth is required.")]
        public DateTime DateOfBirth { get; set; }

        public DateTime? DateOfDeath { get; set; }

        [Required(ErrorMessage = "Country is required.")]
        public int CountryId { get; set; }

        [MaxLength(255, ErrorMessage = "Website must not exceed 255 characters.")]
        public string? Website { get; set; }

        public byte[]? PhotoUrl { get; set; }
        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            
            if (DateOfBirth > DateTime.Today)
            {
                yield return new ValidationResult("Date of birth cannot be in the future.", new[] { nameof(DateOfBirth) });
            }

            if (DateOfDeath.HasValue)
            {
                if (DateOfDeath.Value > DateTime.Today)
                {
                    yield return new ValidationResult("Date of death cannot be in the future.", new[] { nameof(DateOfDeath) });
                }

                if (DateOfDeath.Value < DateOfBirth)
                {
                    yield return new ValidationResult("Date of death cannot be before date of birth.", new[] { nameof(DateOfDeath) });
                }
            }
        }
    }
}