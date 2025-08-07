using BookWorm.Model.SearchObjects;

namespace BookWorm.Model.SearchObjects
{
    public class BookClubSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? CreatorName { get; set; }
        public int? CreatorId { get; set; }
        public bool? IsMember { get; set; }
        public bool? IsCreator { get; set; }
    }
} 