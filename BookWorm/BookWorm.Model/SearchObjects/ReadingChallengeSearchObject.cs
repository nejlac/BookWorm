namespace BookWorm.Model.SearchObjects
{
    public class ReadingChallengeSearchObject : BaseSearchObject
    {
        public string? Username { get; set; }
        public int? Year { get; set; }
        public bool? IsCompleted { get; set; }
    }
} 