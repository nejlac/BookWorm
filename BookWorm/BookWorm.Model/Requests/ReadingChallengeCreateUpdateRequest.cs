using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class ReadingChallengeCreateUpdateRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int Goal { get; set; }

        [Required]
        public int Year { get; set; }

        public List<int> BookIds { get; set; } = new List<int>();

        public bool IsCompleted { get; set; } = false;
    }
} 