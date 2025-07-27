using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Responses
{
    public class QuoteResponse
    {
        public int Id { get; set; }
        
        public int? UserId { get; set; }
        public int BookId { get; set; }
        public string QuoteText { get; set; } = string.Empty;
    }
}
