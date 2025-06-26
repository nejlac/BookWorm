using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.SearchObjects
{
    public class AuthorSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? CountryId { get; set; }
        
    }
}
