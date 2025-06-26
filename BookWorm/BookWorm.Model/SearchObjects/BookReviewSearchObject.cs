namespace BookWorm.Model.SearchObjects
{
    public class BookReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? BookId { get; set; }
        public int? Rating { get; set; }
        public bool? IsChecked { get; set; }
    }
} 