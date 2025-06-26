namespace BookWorm.Model.SearchObjects
{
    public class ReadingChallengeSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? Year { get; set; }
        public bool? IsCompleted { get; set; }
    }
} 