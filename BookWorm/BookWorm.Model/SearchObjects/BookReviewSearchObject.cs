namespace BookWorm.Model.SearchObjects
{
    public class BookReviewSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public string? BookTitle { get; set; }
        public int? Rating { get; set; }
        public bool? IsChecked { get; set; }
    }
} 