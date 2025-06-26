namespace BookWorm.Model.SearchObjects
{
    public class ReadingListSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public string? Name { get; set; }
        public bool? IsPublic { get; set; }
    }
} 