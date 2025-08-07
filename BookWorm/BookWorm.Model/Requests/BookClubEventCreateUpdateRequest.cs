using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class BookClubEventCreateUpdateRequest : IValidatableObject
    {
        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        [Required]
        [MaxLength(700)]
        public string Description { get; set; } = string.Empty;

        [Required]
        public DateTime Deadline { get; set; }

        [Required]
        public int BookId { get; set; }

        [Required]
        public int BookClubId { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (Deadline <= DateTime.UtcNow)
            {
                yield return new ValidationResult("Deadline cannot be in the past.", new[] { nameof(Deadline) });
            }

            if (Deadline > DateTime.UtcNow.AddYears(1))
            {
                yield return new ValidationResult("Deadline cannot be more than a year in the future.", new[] { nameof(Deadline) });
            }
        }
    }
} 