using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.SearchObjects
{
    public class QuoteSearchObject:BaseSearchObject
    {
        public int? BookId { get; set; }
        public int? UserId { get; set; }
    }
}
