using System.Collections.Generic;

namespace BookWorm.Model.Responses
{
    public class UserRatingStatisticsResponse
    {
        public double AverageRating { get; set; }
        public int TotalReviews { get; set; }
        public Dictionary<double, int> RatingDistribution { get; set; } = new Dictionary<double, int>();
    }
} 