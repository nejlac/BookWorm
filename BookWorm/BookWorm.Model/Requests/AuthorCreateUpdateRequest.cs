using System;
using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class AuthorCreateUpdateRequest
    {
        [Required]
        [MaxLength(255)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [MaxLength(1000)]
        public string Biography { get; set; } = string.Empty;

        public DateTime DateOfBirth { get; set; }

        public DateTime? DateOfDeath { get; set; }

        [Required]
        public int CountryId { get; set; }

        [MaxLength(255)]
        public string? Website { get; set; }

        [MaxLength(255)]
        public byte[]? PhotoUrl { get; set; }
    }
} 