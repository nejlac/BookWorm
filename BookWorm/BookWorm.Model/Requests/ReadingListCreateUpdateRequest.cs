using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class ReadingListCreateUpdateRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        public bool IsPublic { get; set; } = true;

        public List<int> BookIds { get; set; } = new List<int>();
    }
} 