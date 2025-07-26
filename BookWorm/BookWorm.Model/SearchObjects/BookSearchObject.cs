using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.SearchObjects
{
    public class BookSearchObject:BaseSearchObject
    {
        public string? Title { get; set; }
        public string? Author { get; set; }
        public int? AuthorId { get; set; }
        public int? GenreId { get; set; }
        public int? PublicationYear { get; set; }
        public int? PageCount { get; set; }
        public int? MinPageCount { get; set; }
        public int? MaxPageCount { get; set; }
        public string? SortBy { get; set; }
        public string? Status { get; set; }
    }
}
