using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace BookWorm.Model.Requests
{
    public class ReadingChallengeCreateUpdateRequest
    {
        [Required(ErrorMessage = "UserId is required.")]
        public int UserId { get; set; }

        [Required(ErrorMessage = "Goal is required.")]
        [Range(1, 1000, ErrorMessage = "Goal must be greater than 0 and less than 1000")]
        public int Goal { get; set; }

        [Required(ErrorMessage = "Year is required.")]
        public int Year { get; set; }

        public List<int> BookIds { get; set; } = new List<int>();

        public bool IsCompleted { get; set; } = false;
    }
} 