namespace BookWorm.Model.Responses
{
    public class BookRatingResponse
    {
        public int BookId { get; set; }
        public string BookTitle { get; set; } = string.Empty;
        public double AverageRating { get; set; }
        public int RatingCount { get; set; }
    }
} 