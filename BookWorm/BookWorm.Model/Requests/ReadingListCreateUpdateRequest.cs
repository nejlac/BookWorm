using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class ReadingListCreateUpdateRequest
    {
        [Required(ErrorMessage = "UserId is required.")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Name is required.")]
        [MaxLength(100, ErrorMessage = "Name must not exceed 100 characters.")]
        public string Name { get; set; } = string.Empty;

        public bool IsPublic { get; set; } = true;


        public List<int> BookIds { get; set; } = new List<int>();
    }
} 