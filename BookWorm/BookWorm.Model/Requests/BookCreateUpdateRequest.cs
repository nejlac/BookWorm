using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class BookCreateUpdateRequest :IValidatableObject
    {
        [Required(ErrorMessage = "Title is required.")]
        [MaxLength(255, ErrorMessage = "Title must not exceed 255 characters.")]
        public string Title { get; set; } = string.Empty;

        [Required(ErrorMessage = "Author is required.")]
        public int AuthorId { get; set; }

        [Required(ErrorMessage = "Description is required.")]
        [MaxLength(1000, ErrorMessage = "Description must not exceed 1000 characters.")]
        public string Description { get; set; } = string.Empty;

        [Required(ErrorMessage = "Publication year is required.")]
        public int PublicationYear { get; set; }

        [Required(ErrorMessage = "Page count is required.")]
        public int PageCount { get; set; }

        public string? CoverImagePath { get; set; }

        public List<int> GenreIds { get; set; } = new List<int>();

        public int? CreatedByUserId { get; set; }

    
     public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            if (PublicationYear > DateTime.Today.Year)
            {
                yield return new ValidationResult("Publication year cannot be in the future.", new[] { nameof(PublicationYear) });
            }

           if (PageCount <= 0)
            {
                yield return new ValidationResult("Page count must be a positive number.", new[] { nameof(PageCount) });
            }
            if (GenreIds == null || GenreIds.Count == 0)
            {
            yield return new ValidationResult("At least one genre must be selected.", new[] { nameof(GenreIds) }); 
            }
        }
    }
  }