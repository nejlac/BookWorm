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
            new Country { Name = "Japan" },
            new Country { Name = "Afghanistan" },
            new Country { Name = "Albania" },
            new Country { Name = "Algeria" },
            new Country { Name = "Andorra" },
            new Country { Name = "Angola" },
            new Country { Name = "Antigua and Barbuda" },
            new Country { Name = "Argentina" },
            new Country { Name = "Armenia" },
            new Country { Name = "Australia" },
            new Country { Name = "Austria" },
            new Country { Name = "Azerbaijan" },
            new Country { Name = "Bahamas" },
            new Country { Name = "Bahrain" },
            new Country { Name = "Bangladesh" },
            new Country { Name = "Barbados" },
            new Country { Name = "Belarus" },
            new Country { Name = "Belgium" },
            new Country { Name = "Belize" },
            new Country { Name = "Benin" },
            new Country { Name = "Bhutan" },
            new Country { Name = "Bolivia" },
            new Country { Name = "Botswana" },
            new Country { Name = "Brazil" },
            new Country { Name = "Brunei" },
            new Country { Name = "Bulgaria" },
            new Country { Name = "Burkina Faso" },
            new Country { Name = "Burundi" },
            new Country { Name = "Cabo Verde" },
            new Country { Name = "Cambodia" },
            new Country { Name = "Cameroon" },
            new Country { Name = "Canada" },
            new Country { Name = "Central African Republic" },
            new Country { Name = "Chad" },
            new Country { Name = "Chile" },
            new Country { Name = "China" },
            new Country { Name = "Comoros" },
            new Country { Name = "Congo (Congo-Brazzaville)" },
            new Country { Name = "Costa Rica" },
            new Country { Name = "Croatia" },
            new Country { Name = "Cuba" },
            new Country { Name = "Democratic Republic of the Congo" },
            new Country { Name = "Denmark" },
            new Country { Name = "Djibouti" },
            new Country { Name = "Dominica" },
            new Country { Name = "Dominican Republic" },
            new Country { Name = "Ecuador" },
            new Country { Name = "Egypt" },
            new Country { Name = "El Salvador" },
            new Country { Name = "Equatorial Guinea" },
            new Country { Name = "Eritrea" },
            new Country { Name = "Estonia" },
            new Country { Name = "Eswatini" },
            new Country { Name = "Ethiopia" },
            new Country { Name = "Fiji" },
            new Country { Name = "Finland" },
            new Country { Name = "Gabon" },
            new Country { Name = "Gambia" },
            new Country { Name = "Georgia" },
            new Country { Name = "Ghana" },
            new Country { Name = "Greece" },
            new Country { Name = "Grenada" },
            new Country { Name = "Guatemala" },
            new Country { Name = "Guinea" },
            new Country { Name = "Guinea-Bissau" },
            new Country { Name = "Guyana" },
            new Country { Name = "Haiti" },
            new Country { Name = "Honduras" },
            new Country { Name = "Hungary" },
            new Country { Name = "Iceland" },
            new Country { Name = "India" },
            new Country { Name = "Indonesia" },
            new Country { Name = "Iran" },
            new Country { Name = "Iraq" },
            new Country { Name = "Ireland" },
            new Country { Name = "Israel" },
            new Country { Name = "Ivory Coast" },
            new Country { Name = "Jamaica" },
            new Country { Name = "Jordan" },
            new Country { Name = "Kazakhstan" },
            new Country { Name = "Kenya" },
            new Country { Name = "Kiribati" },
            new Country { Name = "Kuwait" },
            new Country { Name = "Kyrgyzstan" },
            new Country { Name = "Laos" },
            new Country { Name = "Latvia" },
            new Country { Name = "Lebanon" },
            new Country { Name = "Lesotho" },
            new Country { Name = "Liberia" },
            new Country { Name = "Libya" },
            new Country { Name = "Liechtenstein" },
            new Country { Name = "Lithuania" },
            new Country { Name = "Luxembourg" },
            new Country { Name = "Madagascar" },
            new Country { Name = "Malawi" },
            new Country { Name = "Malaysia" },
            new Country { Name = "Maldives" },
            new Country { Name = "Mali" },
            new Country { Name = "Malta" },
            new Country { Name = "Marshall Islands" },
            new Country { Name = "Mauritania" },
            new Country { Name = "Mauritius" },
            new Country { Name = "Mexico" },
            new Country { Name = "Micronesia" },
            new Country { Name = "Moldova" },
            new Country { Name = "Monaco" },
            new Country { Name = "Mongolia" },
            new Country { Name = "Montenegro" },
            new Country { Name = "Morocco" },
            new Country { Name = "Mozambique" },
            new Country { Name = "Myanmar (Burma)" },
            new Country { Name = "Namibia" },
            new Country { Name = "Nauru" },
            new Country { Name = "Nepal" },
            new Country { Name = "Netherlands" },
            new Country { Name = "New Zealand" },
            new Country { Name = "Nicaragua" },
            new Country { Name = "Niger" },
            new Country { Name = "Nigeria" },
            new Country { Name = "North Korea" },
            new Country { Name = "North Macedonia" },
            new Country { Name = "Norway" },
            new Country { Name = "Oman" },
            new Country { Name = "Pakistan" },
            new Country { Name = "Palau" },
            new Country { Name = "Palestine State" },
            new Country { Name = "Panama" },
            new Country { Name = "Papua New Guinea" },
            new Country { Name = "Paraguay" },
            new Country { Name = "Peru" },
            new Country { Name = "Philippines" },
            new Country { Name = "Poland" },
            new Country { Name = "Portugal" },
            new Country { Name = "Qatar" },
            new Country { Name = "Romania" },
            new Country { Name = "Rwanda" },
            new Country { Name = "Saint Kitts and Nevis" },
            new Country { Name = "Saint Lucia" },
            new Country { Name = "Saint Vincent and the Grenadines" },
            new Country { Name = "Samoa" },
            new Country { Name = "San Marino" },
            new Country { Name = "Sao Tome and Principe" },
            new Country { Name = "Saudi Arabia" },
            new Country { Name = "Senegal" },
            new Country { Name = "Serbia" },
            new Country { Name = "Seychelles" },
            new Country { Name = "Sierra Leone" },
            new Country { Name = "Singapore" },
            new Country { Name = "Slovakia" },
            new Country { Name = "Slovenia" },
            new Country { Name = "Solomon Islands" },
            new Country { Name = "Somalia" },
            new Country { Name = "South Africa" },
            new Country { Name = "South Korea" },
            new Country { Name = "South Sudan" },
            new Country { Name = "Spain" },
            new Country { Name = "Sri Lanka" },
            new Country { Name = "Sudan" },
            new Country { Name = "Suriname" },
            new Country { Name = "Sweden" },
            new Country { Name = "Switzerland" },
            new Country { Name = "Syria" },
            new Country { Name = "Tajikistan" },
            new Country { Name = "Tanzania" },
            new Country { Name = "Thailand" },
            new Country { Name = "Timor-Leste" },
            new Country { Name = "Togo" },
            new Country { Name = "Tonga" },
            new Country { Name = "Trinidad and Tobago" },
            new Country { Name = "Tunisia" },
            new Country { Name = "Turkey" },
            new Country { Name = "Turkmenistan" },
            new Country { Name = "Tuvalu" },
            new Country { Name = "Uganda" },
            new Country { Name = "Ukraine" },
            new Country { Name = "United Arab Emirates" },
            new Country { Name = "Uruguay" },
            new Country { Name = "Uzbekistan" },
            new Country { Name = "Vanuatu" },
            new Country { Name = "Vatican City" },
            new Country { Name = "Venezuela" },
            new Country { Name = "Vietnam" },
            new Country { Name = "Yemen" },
            new Country { Name = "Zambia" },
            new Country { Name = "Zimbabwe" }
        };
                // Sort countries alphabetically by name
                countries = countries.OrderBy(c => c.Name).ToList();
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
                // Always get country by name to ensure correct CountryId
                var uk = _context.Countries.First(c => c.Name == "United Kingdom");
                var usa = _context.Countries.First(c => c.Name == "USA");
                var russia = _context.Countries.First(c => c.Name == "Russia");
                var colombia = _context.Countries.First(c => c.Name == "Colombia");
                var czech = _context.Countries.First(c => c.Name == "Czech Republic");
                var adminUser = _context.Users
                   .Include(u => u.UserRoles)
                   .ThenInclude(ur => ur.Role)
                   .FirstOrDefault(u => u.UserRoles.Any(ur => ur.Role.Name == "Admin"));
                int? adminUserId = adminUser?.Id;
                var authors = new List<Author>
        {
            new Author { Name = "George Orwell", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1903, 6, 25), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId },
            new Author { Name = "J.K. Rowling", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1965, 7, 31), Website = "...", PhotoUrl = null, AuthorState="Accepted", CreatedByUserId=adminUserId},
            new Author { Name = "J.R.R. Tolkien", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1892, 1, 3), Website = "...", PhotoUrl =null ,  AuthorState="Accepted", CreatedByUserId=adminUserId},
            new Author {Name = "Jane Austen", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1775, 12, 16), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Mark Twain", Biography = "...", CountryId = usa.Id, DateOfBirth = new DateTime(1835, 11, 30), Website = "...", PhotoUrl = null, AuthorState="Accepted", CreatedByUserId=adminUserId },
            new Author {Name = "F. Scott Fitzgerald", Biography = "...", CountryId = usa.Id, DateOfBirth = new DateTime(1896, 9, 24), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author {Name = "Ernest Hemingway", Biography = "...", CountryId = usa.Id, DateOfBirth = new DateTime(1899, 7, 21), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author {Name = "Harper Lee", Biography = "...", CountryId = usa.Id, DateOfBirth = new DateTime(1926, 4, 28), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author {Name = "Leo Tolstoy", Biography = "...", CountryId = russia.Id, DateOfBirth = new DateTime(1828, 9, 9), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Mary Shelley", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1797, 8, 30), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Agatha Christie", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1890, 9, 15), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Charles Dickens", Biography = "...", CountryId = uk.Id, DateOfBirth = new DateTime(1812, 2, 7), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId },
            new Author { Name = "Gabriel García Márquez", Biography = "...", CountryId = colombia.Id, DateOfBirth = new DateTime(1927, 3, 6), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Franz Kafka", Biography = "...", CountryId = czech.Id, DateOfBirth = new DateTime(1883, 7, 3), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Fyodor Dostoevsky", Biography = "...", CountryId = russia.Id, DateOfBirth = new DateTime(1821, 11, 11), Website = "...", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId}
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
                var adminUser = _context.Users
                    .Include(u => u.UserRoles)
                    .ThenInclude(ur => ur.Role)
                    .FirstOrDefault(u => u.UserRoles.Any(ur => ur.Role.Name == "Admin"));
                int? adminUserId = adminUser?.Id;

                var books = new List<Book>
    {
        new Book { Title = "1984", AuthorId = GetAuthorId("George Orwell"), Description = "Dystopian novel.", PublicationYear = 1949, PageCount = 328, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Animal Farm", AuthorId = GetAuthorId("George Orwell"), Description = "Political allegory.", PublicationYear = 1945, PageCount = 112, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Harry Potter and the Sorcerer's Stone", AuthorId = GetAuthorId("J.K. Rowling"), Description = "First in Harry Potter series.", PublicationYear = 1997, PageCount = 309, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Harry Potter and the Chamber of Secrets", AuthorId = GetAuthorId("J.K. Rowling"), Description = "Second in Harry Potter series.", PublicationYear = 1998, PageCount = 341, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Hobbit", AuthorId = GetAuthorId("J.R.R. Tolkien"), Description = "Fantasy adventure.", PublicationYear = 1937, PageCount = 310, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Fellowship of the Ring", AuthorId = GetAuthorId("J.R.R. Tolkien"), Description = "First part of LOTR.", PublicationYear = 1954, PageCount = 423, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Pride and Prejudice", AuthorId = GetAuthorId("Jane Austen"), Description = "Romantic novel.", PublicationYear = 1813, PageCount = 279, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Emma", AuthorId = GetAuthorId("Jane Austen"), Description = "Another novel by Austen.", PublicationYear = 1815, PageCount = 474, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Adventures of Huckleberry Finn", AuthorId = GetAuthorId("Mark Twain"), Description = "Classic American novel.", PublicationYear = 1884, PageCount = 366, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Adventures of Tom Sawyer", AuthorId = GetAuthorId("Mark Twain"), Description = "Another classic.", PublicationYear = 1876, PageCount = 274, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Great Gatsby", AuthorId = GetAuthorId("F. Scott Fitzgerald"), Description = "A story of the Jazz Age.", PublicationYear = 1925, PageCount = 180, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "To Kill a Mockingbird", AuthorId = GetAuthorId("Harper Lee"), Description = "Classic of modern American literature.", PublicationYear = 1960, PageCount = 281, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Frankenstein", AuthorId = GetAuthorId("Mary Shelley"), Description = "Gothic novel.", PublicationYear = 1818, PageCount = 280, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Murder on the Orient Express", AuthorId = GetAuthorId("Agatha Christie"), Description = "Hercule Poirot mystery.", PublicationYear = 1934, PageCount = 256, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "A Tale of Two Cities", AuthorId = GetAuthorId("Charles Dickens"), Description = "Historical novel.", PublicationYear = 1859, PageCount = 489, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Love in the Time of Cholera", AuthorId = GetAuthorId("Gabriel García Márquez"), Description = "Romantic novel.", PublicationYear = 1985, PageCount = 348, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Trial", AuthorId = GetAuthorId("Franz Kafka"), Description = "Existential novel.", PublicationYear = 1925, PageCount = 255, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Crime and Punishment", AuthorId = GetAuthorId("Fyodor Dostoevsky"), Description = "Psychological novel.", PublicationYear = 1866, PageCount = 671, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "War and Peace", AuthorId = GetAuthorId("Leo Tolstoy"), Description = "Epic historical novel.", PublicationYear = 1869, PageCount = 1225, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Old Man and the Sea", AuthorId = GetAuthorId("Ernest Hemingway"), Description = "Short novel about struggle.", PublicationYear = 1952, PageCount = 127, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId }
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
                        new ReadingList { UserId = user.Id, Name = "Want to read", Description = "Books I want to read", IsPublic = true, CreatedAt = DateTime.Now },
                        new ReadingList { UserId = user.Id, Name = "Currently reading", Description = "Books I am currently reading", IsPublic = true, CreatedAt = DateTime.Now },
                        new ReadingList { UserId = user.Id, Name = "Read", Description = "Books I have read", IsPublic = true, CreatedAt = DateTime.Now }
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