using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Requests
{
    public class QuoteCreateUpdateRequest
    {
 
        public int? UserId { get; set; }

        [Required(ErrorMessage = "BookId is required")]
        public int BookId { get; set; }

        [Required(ErrorMessage = "Quote is required")]
        [MaxLength(10000,ErrorMessage ="Quote must have less than 10 000 characters")]
        public string QuoteText { get; set; }

    }
}
