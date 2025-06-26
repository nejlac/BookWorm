using BookWorm.Services.DataBase;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BookWormWebAPI.Controllers
{

    [ApiController]
    [Route("api/[controller]")]
    public class SeedController : ControllerBase
    {
        private readonly BookWormDbContext _context;

        public SeedController(BookWormDbContext context)
        {
            _context = context;
        }

        [HttpPost("init")]

        public async Task<IActionResult> SeedData()
        {
            if (!_context.Countries.Any())
            {
                var countries = new List<Country>
        {
            new Country { Name = "United Kingdom" },
            new Country { Name = "USA" },
            new Country { Name = "Russia" },
            new Country { Name = "Colombia" },
            new Country { Name = "Czech Republic" },
            new Country { Name = "Bosnia and Herzegovina" },
            new Country { Name = "France" },
            new Country { Name = "Germany" },
            new Country { Name = "Italy" },
            new Country { Name = "Japan" }
        };
                await _context.Countries.AddRangeAsync(countries);
                await _context.SaveChangesAsync();
            }

            if (!_context.Roles.Any())
            {
                var roles = new List<Role>
        {
            new Role{ Name = "Admin", Description = "Admin moderates whole application" },
            new Role{ Name = "User", Description = "Basic user" }
        };
                await _context.Roles.AddRangeAsync(roles);
                await _context.SaveChangesAsync();
            }
            if (!_context.Users.Any())
            {
                
                var userRole = _context.Roles.First(r => r.Name == "User");

             
                var country = _context.Countries.First();

                var user = new User
                {
                    FirstName = "Test",
                    LastName = "User",
                    Email = "testuser@example.com",
                    Username = "testuser",
                    PasswordHash = "hashed_password_here",
                    PasswordSalt = "salt_here",
                    CountryId = country.Id,
                    Age = 25,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow,
                    PhoneNumber = "+38760123456"
                };

                
                user.UserRoles.Add(new UserRole
                {
                    RoleId = userRole.Id,
                    User = user
                });

                _context.Users.Add(user);
                await _context.SaveChangesAsync();
            }



            if (!_context.Authors.Any())
            {
                var uk = GetCountry("United Kingdom");
                var usa = GetCountry("USA");
                var russia = GetCountry("Russia");
                var colombia = GetCountry("Colombia");
                var czech = GetCountry("Czech Republic");

                var authors = new List<Author>
        {
            new Author { Name = "George Orwell", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1903, 6, 25), Website = "...", PhotoUrl = new byte[]{ } },
            new Author { Name = "J.K. Rowling", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1965, 7, 31), Website = "...", PhotoUrl = new byte[] {  } },
            new Author { Name = "J.R.R. Tolkien", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1892, 1, 3), Website = "...", PhotoUrl = new byte[] {  } },
            new Author { Name = "Jane Austen", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1775, 12, 16), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Mark Twain", Biography = "...", CountryId = usa.Id, DateOfBirth = new DateTime(1835, 11, 30), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "F. Scott Fitzgerald", Biography = "...", CountryId = usa.Id, DateOfBirth = new DateTime(1896, 9, 24), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Ernest Hemingway", Biography = "...", CountryId = usa.Id, DateOfBirth = new DateTime(1899, 7, 21), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Harper Lee", Biography = "...", CountryId = usa.Id, DateOfBirth = new DateTime(1926, 4, 28), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Leo Tolstoy", Biography = "...", CountryId = russia.Id, DateOfBirth = new DateTime(1828, 9, 9), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Mary Shelley", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1797, 8, 30), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Agatha Christie", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1890, 9, 15), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Charles Dickens", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1812, 2, 7), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Gabriel García Márquez", Biography = "...", CountryId = colombia.Id, DateOfBirth = new DateTime(1927, 3, 6), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Franz Kafka", Biography = "...", CountryId = czech.Id, DateOfBirth = new DateTime(1883, 7, 3), Website = "...", PhotoUrl = new byte[] {} },
            new Author { Name = "Fyodor Dostoevsky", Biography = "...", CountryId = russia.Id, DateOfBirth = new DateTime(1821, 11, 11), Website = "...", PhotoUrl = new byte[] { 0xFF } }
        };

                await _context.Authors.AddRangeAsync(authors);
                await _context.SaveChangesAsync();
            }

            if (!_context.Genres.Any())
            {
                var genres = new List<Genre>
        {
            new Genre { Name = "Fantasy", Description = "Fantasy genre" },
            new Genre { Name = "Science Fiction", Description = "Sci-fi genre" },
            new Genre { Name = "Romance", Description = "Romantic genre" },
            new Genre { Name = "Mystery", Description = "Mystery and detective genre" },
            new Genre { Name = "Historical", Description = "Historical fiction" },
            new Genre { Name = "Horror", Description = "Horror and supernatural" },
            new Genre { Name = "Biography", Description = "Life stories" },
            new Genre { Name = "Adventure", Description = "Adventurous tales" },
            new Genre { Name = "Classics", Description = "Classic literature" },
            new Genre { Name = "Drama", Description = "Dramatic works" }
        };
                await _context.Genres.AddRangeAsync(genres);
                await _context.SaveChangesAsync();
            }

            if (!_context.Books.Any())
            {
                var now = DateTime.Now;

                var books = new List<Book>
    {
        new Book { Title = "1984", AuthorId = GetAuthorId("George Orwell"), Description = "Dystopian novel.", PublicationYear = 1949, PageCount = 328, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Animal Farm", AuthorId = GetAuthorId("George Orwell"), Description = "Political allegory.", PublicationYear = 1945, PageCount = 112, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Harry Potter and the Sorcerer's Stone", AuthorId = GetAuthorId("J.K. Rowling"), Description = "First in Harry Potter series.", PublicationYear = 1997, PageCount = 309, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Harry Potter and the Chamber of Secrets", AuthorId = GetAuthorId("J.K. Rowling"), Description = "Second in Harry Potter series.", PublicationYear = 1998, PageCount = 341, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "The Hobbit", AuthorId = GetAuthorId("J.R.R. Tolkien"), Description = "Fantasy adventure.", PublicationYear = 1937, PageCount = 310, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "The Fellowship of the Ring", AuthorId = GetAuthorId("J.R.R. Tolkien"), Description = "First part of LOTR.", PublicationYear = 1954, PageCount = 423, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Pride and Prejudice", AuthorId = GetAuthorId("Jane Austen"), Description = "Romantic novel.", PublicationYear = 1813, PageCount = 279, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Emma", AuthorId = GetAuthorId("Jane Austen"), Description = "Another novel by Austen.", PublicationYear = 1815, PageCount = 474, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Adventures of Huckleberry Finn", AuthorId = GetAuthorId("Mark Twain"), Description = "Classic American novel.", PublicationYear = 1884, PageCount = 366, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "The Adventures of Tom Sawyer", AuthorId = GetAuthorId("Mark Twain"), Description = "Another classic.", PublicationYear = 1876, PageCount = 274, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "The Great Gatsby", AuthorId = GetAuthorId("F. Scott Fitzgerald"), Description = "A story of the Jazz Age.", PublicationYear = 1925, PageCount = 180, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "To Kill a Mockingbird", AuthorId = GetAuthorId("Harper Lee"), Description = "Classic of modern American literature.", PublicationYear = 1960, PageCount = 281, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Frankenstein", AuthorId = GetAuthorId("Mary Shelley"), Description = "Gothic novel.", PublicationYear = 1818, PageCount = 280, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Murder on the Orient Express", AuthorId = GetAuthorId("Agatha Christie"), Description = "Hercule Poirot mystery.", PublicationYear = 1934, PageCount = 256, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "A Tale of Two Cities", AuthorId = GetAuthorId("Charles Dickens"), Description = "Historical novel.", PublicationYear = 1859, PageCount = 489, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Love in the Time of Cholera", AuthorId = GetAuthorId("Gabriel García Márquez"), Description = "Romantic novel.", PublicationYear = 1985, PageCount = 348, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "The Trial", AuthorId = GetAuthorId("Franz Kafka"), Description = "Existential novel.", PublicationYear = 1925, PageCount = 255, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "Crime and Punishment", AuthorId = GetAuthorId("Fyodor Dostoevsky"), Description = "Psychological novel.", PublicationYear = 1866, PageCount = 671, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "War and Peace", AuthorId = GetAuthorId("Leo Tolstoy"), Description = "Epic historical novel.", PublicationYear = 1869, PageCount = 1225, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now },
        new Book { Title = "The Old Man and the Sea", AuthorId = GetAuthorId("Ernest Hemingway"), Description = "Short novel about struggle.", PublicationYear = 1952, PageCount = 127, CoverImageUrl = new byte[] {}, CreatedAt = now, UpdatedAt = now }
    };

                await _context.Books.AddRangeAsync(books);
                await _context.SaveChangesAsync();
            }


            if (!_context.BookGenres.Any())
            {
                var bookGenres = new List<BookGenre>
    {
        new BookGenre { BookId = GetBookId("1984"), GenreId = GetGenreId("Science Fiction") },
        new BookGenre { BookId = GetBookId("Animal Farm"), GenreId = GetGenreId("Classics") },
        new BookGenre { BookId = GetBookId("Harry Potter and the Sorcerer's Stone"), GenreId = GetGenreId("Fantasy") },
        new BookGenre { BookId = GetBookId("Harry Potter and the Chamber of Secrets"), GenreId = GetGenreId("Fantasy") },
        new BookGenre { BookId = GetBookId("The Hobbit"), GenreId = GetGenreId("Fantasy") },
        new BookGenre { BookId = GetBookId("The Fellowship of the Ring"), GenreId = GetGenreId("Adventure") },
        new BookGenre { BookId = GetBookId("Pride and Prejudice"), GenreId = GetGenreId("Romance") },
        new BookGenre { BookId = GetBookId("Emma"), GenreId = GetGenreId("Romance") },
        new BookGenre { BookId = GetBookId("Adventures of Huckleberry Finn"), GenreId = GetGenreId("Adventure") },
        new BookGenre { BookId = GetBookId("The Adventures of Tom Sawyer"), GenreId = GetGenreId("Adventure") },
        new BookGenre { BookId = GetBookId("The Great Gatsby"), GenreId = GetGenreId("Classics") },
        new BookGenre { BookId = GetBookId("To Kill a Mockingbird"), GenreId = GetGenreId("Drama") },
        new BookGenre { BookId = GetBookId("Frankenstein"), GenreId = GetGenreId("Horror") },
        new BookGenre { BookId = GetBookId("Murder on the Orient Express"), GenreId = GetGenreId("Mystery") },
        new BookGenre { BookId = GetBookId("A Tale of Two Cities"), GenreId = GetGenreId("Historical") },
        new BookGenre { BookId = GetBookId("Love in the Time of Cholera"), GenreId = GetGenreId("Romance") },
        new BookGenre { BookId = GetBookId("The Trial"), GenreId = GetGenreId("Drama") },
        new BookGenre { BookId = GetBookId("Crime and Punishment"), GenreId = GetGenreId("Drama") },
        new BookGenre { BookId = GetBookId("War and Peace"), GenreId = GetGenreId("Historical") },
        new BookGenre { BookId = GetBookId("The Old Man and the Sea"), GenreId = GetGenreId("Classics") }
    };

                await _context.BookGenres.AddRangeAsync(bookGenres);
                await _context.SaveChangesAsync();
            }


            if (!_context.ReadingLists.Any())
            {
                var users = await _context.Users.ToListAsync();

                var readingLists = new List<ReadingList>();

                foreach (var user in users)
                {
                    readingLists.AddRange(new[]
                    {
                new ReadingList { UserId = user.Id, Name = "Want to read", IsPublic = true, CreatedAt = DateTime.Now },
                new ReadingList { UserId = user.Id, Name = "Currently reading", IsPublic = true, CreatedAt = DateTime.Now },
                new ReadingList { UserId = user.Id, Name = "Read", IsPublic = true, CreatedAt = DateTime.Now }
            });
                }

                await _context.ReadingLists.AddRangeAsync(readingLists);
                await _context.SaveChangesAsync();

            }


            return Ok("Data seeded successfully.");

        }


        private Country GetCountry(string name) =>
        _context.Countries.FirstOrDefault(c => c.Name == name)
        ?? throw new InvalidOperationException($"Country '{name}' not found.");

        private int GetAuthorId(string name) =>
            _context.Authors.FirstOrDefault(a => a.Name == name)?.Id
            ?? throw new InvalidOperationException($"Author '{name}' not found.");

        private int GetBookId(string title) =>
            _context.Books.FirstOrDefault(b => b.Title == title)?.Id
            ?? throw new InvalidOperationException($"Book '{title}' not found.");

        private int GetGenreId(string name) =>
            _context.Genres.FirstOrDefault(g => g.Name == name)?.Id
            ?? throw new InvalidOperationException($"Genre '{name}' not found.");
    }



}