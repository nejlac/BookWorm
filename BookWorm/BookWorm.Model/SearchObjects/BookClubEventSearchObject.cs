using BookWorm.Model.SearchObjects;

namespace BookWorm.Model.SearchObjects
{
    public class BookClubEventSearchObject : BaseSearchObject
    {
        public string? Title { get; set; }
        public int? BookClubId { get; set; }
        public int? BookId { get; set; }
        public int? CreatorId { get; set; }
        public bool? IsParticipant { get; set; }
        public bool? IsCreator { get; set; }
        public bool? IsCompleted { get; set; }
    }
} 