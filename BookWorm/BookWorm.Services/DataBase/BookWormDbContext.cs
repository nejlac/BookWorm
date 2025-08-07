using Microsoft.EntityFrameworkCore;

namespace BookWorm.Services.DataBase
{
    public class BookWormDbContext : DbContext
    {
        public BookWormDbContext(DbContextOptions<BookWormDbContext> options) : base(options)
        {
        }

       public DbSet<User> Users { get; set; }
        public DbSet<UserRole> UserRoles { get; set; }
        public DbSet<Role> Roles { get; set; }
        public DbSet<Author> Authors { get; set; }
        public DbSet<Book> Books { get; set; }
        public DbSet<Genre> Genres { get; set; }
        public DbSet<BookGenre> BookGenres { get; set; }
        
        public DbSet<ReadingList> ReadingLists { get; set; }
        public DbSet<ReadingListBook> ReadingListBooks { get; set; }
        public DbSet<BookReview> BookReviews { get; set; }
        public DbSet<Quote> Quotes { get; set; }
        
        public DbSet<ReadingChallenge> ReadingChallenges { get; set; }
        public DbSet<ReadingChallengeBook> ReadingChallengeBooks { get; set; }
        public DbSet<UserFriend> UserFriends { get; set; }
        public DbSet<Country>Countries { get; set; }
        public DbSet<ReadingStreak> ReadingStreaks { get; set; }
        
        public DbSet<BookClub> BookClubs { get; set; }
        public DbSet<BookClubMember> BookClubMembers { get; set; }
        public DbSet<BookClubEvent> BookClubEvents { get; set; }
        public DbSet<BookClubEventParticipant> BookClubEventParticipants { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
           
            

            
            modelBuilder.Entity<BookReview>(entity =>
            {
                entity.HasOne(br => br.User)
                    .WithMany()
                    .HasForeignKey(br => br.UserId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasOne(br => br.Book)
                    .WithMany(b => b.BookReviews)
                    .HasForeignKey(br => br.BookId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(e => new { e.UserId, e.BookId }).IsUnique();
            });

            modelBuilder.Entity<Quote>(entity =>
            {
                entity.HasOne(q => q.User)
                    .WithMany()
                    .HasForeignKey(q => q.UserId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasOne(q => q.Book)
                    .WithMany()
                    .HasForeignKey(q => q.BookId)
                    .OnDelete(DeleteBehavior.Cascade);
            });

            modelBuilder.Entity<ReadingListBook>(entity =>
            {
                entity.HasOne(rlb => rlb.ReadingList)
                    .WithMany(rl => rl.ReadingListBooks)
                    .HasForeignKey(rlb => rlb.ReadingListId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(rlb => rlb.Book)
                    .WithMany(b => b.ReadingListBooks)
                    .HasForeignKey(rlb => rlb.BookId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasIndex(e => new { e.ReadingListId, e.BookId }).IsUnique();
            });

            modelBuilder.Entity<ReadingChallengeBook>(entity =>
            {
                entity.HasOne(rcb => rcb.ReadingChallenge)
                    .WithMany(rc => rc.ReadingChallengeBooks)
                    .HasForeignKey(rcb => rcb.ReadingChallengeId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(rcb => rcb.Book)
                    .WithMany(b => b.ReadingChallengeBooks)
                    .HasForeignKey(rcb => rcb.BookId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasIndex(e => new { e.ReadingChallengeId, e.BookId }).IsUnique();
            });

            modelBuilder.Entity<BookGenre>(entity =>
            {
                entity.HasOne(bg => bg.Book)
                    .WithMany(b => b.BookGenres)
                    .HasForeignKey(bg => bg.BookId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(bg => bg.Genre)
                .WithMany(g => g.BookGenres) 
                .HasForeignKey(bg => bg.GenreId)
                .OnDelete(DeleteBehavior.NoAction);


                entity.HasIndex(e => new { e.BookId, e.GenreId }).IsUnique();
            });

            modelBuilder.Entity<Genre>(entity =>
            {
                entity.HasIndex(e => e.Name).IsUnique();
            });
            modelBuilder.Entity<UserFriend>(entity =>
            {
                entity.HasKey(uf => uf.Id);

                entity.HasOne(uf => uf.User)
                    .WithMany(u => u.SentFriendRequests)
                    .HasForeignKey(uf => uf.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(uf => uf.Friend)
                    .WithMany(u => u.ReceivedFriendRequests)
                    .HasForeignKey(uf => uf.FriendId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasIndex(e => new { e.UserId, e.FriendId }).IsUnique();
            });

            modelBuilder.Entity<BookClub>(entity =>
            {
                entity.HasOne(bc => bc.ClubCreator)
                    .WithMany()
                    .HasForeignKey(bc => bc.CreatorId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<BookClubMember>(entity =>
            {
                entity.HasOne(bcm => bcm.User)
                    .WithMany(u => u.BookClubMembers)
                    .HasForeignKey(bcm => bcm.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(bcm => bcm.BookClub)
                    .WithMany(bc => bc.Members)
                    .HasForeignKey(bcm => bcm.BookClubId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(e => new { e.UserId, e.BookClubId }).IsUnique();
            });

            modelBuilder.Entity<BookClubEvent>(entity =>
            {
                entity.HasOne(bce => bce.Book)
                    .WithMany()
                    .HasForeignKey(bce => bce.BookId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(bce => bce.BookClub)
                    .WithMany(bc => bc.Events)
                    .HasForeignKey(bce => bce.BookClubId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(bce => bce.Creator)
                    .WithMany()
                    .HasForeignKey(bce => bce.CreatorId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<BookClubEventParticipant>(entity =>
            {
                entity.HasOne(bcep => bcep.User)
                    .WithMany(u => u.BookClubEventParticipants)
                    .HasForeignKey(bcep => bcep.UserId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(bcep => bcep.BookClubEvent)
                    .WithMany(bce => bce.Participants)
                    .HasForeignKey(bcep => bcep.BookClubEventId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasIndex(e => new { e.UserId, e.BookClubEventId }).IsUnique();
            });

        }
    }
} 