using BookWorm.Services.DataBase;
using BookWorm.Services;
using BookWorm.Model.Requests;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;


namespace BookWormWebAPI.Controllers
{

    [ApiController]
    [Route("api/[controller]")]
    public class SeedController : ControllerBase
    {
        private readonly BookWormDbContext _context;
        private readonly IUserService _userService;
        private readonly IReadingChallengeService _readingChallengeService;

        public SeedController(BookWormDbContext context, IUserService userService, IReadingChallengeService readingChallengeService)
        {
            _context = context;
            _userService = userService;
            _readingChallengeService = readingChallengeService;
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
                var adminRole = _context.Roles.First(r => r.Name == "Admin");
                var bosnia = _context.Countries.First(c => c.Name == "Bosnia and Herzegovina");
                var usa = _context.Countries.First(c => c.Name == "USA");
                var uk = _context.Countries.First(c => c.Name == "United Kingdom");
                var germany = _context.Countries.First(c => c.Name == "Germany");
                var france = _context.Countries.First(c => c.Name == "France");

                // Create users using UserService to handle password hashing
                var userRequests = new[]
                {
                    // Main test user
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Test",
                        LastName = "User",
                        Email = "nejla.cajdin@gmail.com",
                        Username = "testUser",
                        Password = "TestTest123.",
                        CountryId = bosnia.Id,
                        Age = 25,
                        IsActive = true,
                        PhoneNumber = "+38760123456",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    // Additional users
                    new UserCreateUpdateRequest
                    {
                        FirstName = "John",
                        LastName = "Doe",
                        Email = "john.doe@example.com",
                        Username = "john_doe",
                        Password = "Password123!",
                        CountryId = usa.Id,
                        Age = 28,
                        IsActive = true,
                        PhoneNumber = "+1234567890",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Jane",
                        LastName = "Smith",
                        Email = "jane.smith@example.com",
                        Username = "jane_smith",
                        Password = "Password123!",
                        CountryId = uk.Id,
                        Age = 32,
                        IsActive = true,
                        PhoneNumber = "+44123456789",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Michael",
                        LastName = "Johnson",
                        Email = "michael.johnson@example.com",
                        Username = "michael_j",
                        Password = "Password123!",
                        CountryId = usa.Id,
                        Age = 24,
                        IsActive = true,
                        PhoneNumber = "+1234567891",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Sarah",
                        LastName = "Wilson",
                        Email = "sarah.wilson@example.com",
                        Username = "sarah_w",
                        Password = "Password123!",
                        CountryId = uk.Id,
                        Age = 29,
                        IsActive = true,
                        PhoneNumber = "+44123456790",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "David",
                        LastName = "Brown",
                        Email = "david.brown@example.com",
                        Username = "david_brown",
                        Password = "Password123!",
                        CountryId = usa.Id,
                        Age = 35,
                        IsActive = true,
                        PhoneNumber = "+1234567892",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Emma",
                        LastName = "Davis",
                        Email = "emma.davis@example.com",
                        Username = "emma_d",
                        Password = "Password123!",
                        CountryId = germany.Id,
                        Age = 27,
                        IsActive = true,
                        PhoneNumber = "+49123456789",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "James",
                        LastName = "Miller",
                        Email = "james.miller@example.com",
                        Username = "james_m",
                        Password = "Password123!",
                        CountryId = usa.Id,
                        Age = 31,
                        IsActive = true,
                        PhoneNumber = "+1234567893",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Lisa",
                        LastName = "Garcia",
                        Email = "lisa.garcia@example.com",
                        Username = "lisa_g",
                        Password = "Password123!",
                        CountryId = france.Id,
                        Age = 26,
                        IsActive = true,
                        PhoneNumber = "+33123456789",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Robert",
                        LastName = "Taylor",
                        Email = "robert.taylor@example.com",
                        Username = "robert_t",
                        Password = "Password123!",
                        CountryId = uk.Id,
                        Age = 33,
                        IsActive = true,
                        PhoneNumber = "+44123456791",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Maria",
                        LastName = "Anderson",
                        Email = "maria.anderson@example.com",
                        Username = "maria_a",
                        Password = "Password123!",
                        CountryId = usa.Id,
                        Age = 30,
                        IsActive = true,
                        PhoneNumber = "+1234567894",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Thomas",
                        LastName = "Thomas",
                        Email = "thomas.thomas@example.com",
                        Username = "thomas_t",
                        Password = "Password123!",
                        CountryId = germany.Id,
                        Age = 34,
                        IsActive = true,
                        PhoneNumber = "+49123456790",
                        RoleIds = new List<int> { userRole.Id }
                    },
                    new UserCreateUpdateRequest
                    {
                        FirstName = "Admin",
                        LastName = "User",
                        Email = "admin@bookworm.com",
                        Username = "admin",
                        Password = "Admin123!",
                        CountryId = usa.Id,
                        Age = 30,
                        IsActive = true,
                        PhoneNumber = "+1234567895",
                        RoleIds = new List<int> { adminRole.Id }
                    }
                };

                // Create users using UserService
                foreach (var userRequest in userRequests)
                {
                    await _userService.CreateAsync(userRequest);
                }
            }



            if (!_context.Authors.Any())
            {
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
            new Author { Name = "George Orwell", Biography = "Eric Arthur Blair, known by his pen name George Orwell, was an English novelist, essayist, journalist, and critic. His work is characterised by lucid prose, biting social criticism, opposition to totalitarianism, and outspoken support of democratic socialism. Orwell's most famous works include 'Animal Farm' and '1984', both of which are powerful critiques of totalitarianism and political corruption. His writing continues to influence political thought and literature worldwide.", CountryId = uk.Id, DateOfBirth = new DateTime(1903, 6, 25), Website = "https://www.george-orwell.org", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId },
            new Author { Name = "J.K. Rowling", Biography = "Joanne Rowling, known by her pen name J.K. Rowling, is a British author, philanthropist, film producer, television producer, and screenwriter. She is best known for writing the Harry Potter fantasy series, which has won multiple awards and sold more than 500 million copies, becoming the best-selling book series in history. The books have been the basis for a series of films, over which Rowling had overall approval on the scripts and was a producer on the final films.", CountryId = uk.Id, DateOfBirth = new DateTime(1965, 7, 31), Website = "https://www.jkrowling.com", PhotoUrl = null, AuthorState="Accepted", CreatedByUserId=adminUserId},
            new Author { Name = "J.R.R. Tolkien", Biography = "John Ronald Reuel Tolkien was an English writer, poet, philologist, and academic, best known as the author of the high fantasy works 'The Hobbit' and 'The Lord of the Rings'. He was a professor of Anglo-Saxon at Oxford University and a close friend of C.S. Lewis. Tolkien's works have inspired generations of readers and writers, and his influence on the fantasy genre is immeasurable. His detailed world-building and linguistic expertise created Middle-earth, one of the most beloved fictional worlds in literature.", CountryId = uk.Id, DateOfBirth = new DateTime(1892, 1, 3), Website = "https://www.tolkiensociety.org", PhotoUrl =null ,  AuthorState="Accepted", CreatedByUserId=adminUserId},
            new Author {Name = "Jane Austen", Biography = "Jane Austen was an English novelist known primarily for her six major novels, which interpret, critique and comment upon the British landed gentry at the end of the 18th century. Austen's plots often explore the dependence of women on marriage in the pursuit of favourable social standing and economic security. Her works critique the novels of sensibility of the second half of the 18th century and are part of the transition to 19th-century literary realism.", CountryId = uk.Id, DateOfBirth = new DateTime(1775, 12, 16), Website = "https://www.janeausten.org", PhotoUrl = "covers/jane-austen.webp", AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Mark Twain", Biography = "Samuel Langhorne Clemens, known by his pen name Mark Twain, was an American writer, humorist, entrepreneur, publisher, and lecturer. He was lauded as the 'greatest humorist the United States has produced', and William Faulkner called him 'the father of American literature'. His novels include 'The Adventures of Tom Sawyer' and its sequel, 'Adventures of Huckleberry Finn', the latter of which has often been called the Great American Novel.", CountryId = usa.Id, DateOfBirth = new DateTime(1835, 11, 30), Website = "https://www.marktwain.com", PhotoUrl = null, AuthorState="Accepted", CreatedByUserId=adminUserId },
            new Author {Name = "F. Scott Fitzgerald", Biography = "Francis Scott Key Fitzgerald was an American novelist, essayist, screenwriter, and short-story writer. He was best known for his novels depicting the flamboyance and excess of the Jazz Age—a term he popularized. During his lifetime, he published four novels, four story collections, and 164 short stories. Although he achieved temporary popular success and fortune in the 1920s, Fitzgerald received critical acclaim only after his death and is now widely regarded as one of the greatest American writers of the 20th century.", CountryId = usa.Id, DateOfBirth = new DateTime(1896, 9, 24), Website = "https://www.fscottfitzgerald.com", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author {Name = "Ernest Hemingway", Biography = "Ernest Miller Hemingway was an American novelist, short-story writer, and journalist. His economical and understated style—which he termed the iceberg theory—had a strong influence on 20th-century fiction, while his adventurous lifestyle and his public image brought him admiration from later generations. Hemingway produced most of his work between the mid-1920s and the mid-1950s, and won the Nobel Prize in Literature in 1954.", CountryId = usa.Id, DateOfBirth = new DateTime(1899, 7, 21), Website = "https://www.ernesthemingway.com", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author {Name = "Harper Lee", Biography = "Nelle Harper Lee was an American novelist best known for her 1960 novel 'To Kill a Mockingbird'. It won the 1961 Pulitzer Prize and has become a classic of modern American literature. Lee has received numerous accolades and honorary degrees, including the Presidential Medal of Freedom in 2007 which was awarded for her contribution to literature.", CountryId = usa.Id, DateOfBirth = new DateTime(1926, 4, 28), Website = "https://www.harperlee.com", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author {Name = "Leo Tolstoy", Biography = "Count Lev Nikolayevich Tolstoy, usually referred to in English as Leo Tolstoy, was a Russian writer who is regarded as one of the greatest authors of all time. He received nominations for the Nobel Prize in Literature every year from 1902 to 1906 and for the Nobel Peace Prize in 1901, 1902, and 1909. His ideas on nonviolent resistance, expressed in such works as 'The Kingdom of God Is Within You', were to have a profound impact on such pivotal 20th-century figures as Mahatma Gandhi and Martin Luther King Jr.", CountryId = russia.Id, DateOfBirth = new DateTime(1828, 9, 9), Website = "https://www.tolstoy.ru", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Mary Shelley", Biography = "Mary Wollstonecraft Shelley was an English novelist who wrote the Gothic novel 'Frankenstein; or, The Modern Prometheus' in 1818, which is considered an early example of science fiction. She also edited and promoted the works of her husband, the Romantic poet and philosopher Percy Bysshe Shelley. Her father was the political philosopher William Godwin, and her mother was the philosopher and feminist activist Mary Wollstonecraft.", CountryId = uk.Id, DateOfBirth = new DateTime(1797, 8, 30), Website = "https://www.maryshelley.com", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Agatha Christie", Biography = "Dame Agatha Mary Clarissa Christie, Lady Mallowan, DBE was an English writer known for her 66 detective novels and 14 short story collections, particularly those revolving around fictional detectives Hercule Poirot and Miss Marple. She also wrote the world's longest-running play, 'The Mousetrap', which has been performed in the West End since 1952. Guinness World Records lists Christie as the best-selling fiction writer of all time, her novels having sold more than two billion copies.", CountryId = uk.Id, DateOfBirth = new DateTime(1890, 9, 15), Website = "https://www.agathachristie.com", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Charles Dickens", Biography = "Charles John Huffam Dickens was an English writer and social critic. He created some of the world's best-known fictional characters and is regarded by many as the greatest novelist of the Victorian era. His works enjoyed unprecedented popularity during his lifetime, and by the twentieth century critics and scholars had recognised him as a literary genius. His novels and short stories are still widely read today.", CountryId = uk.Id, DateOfBirth = new DateTime(1812, 2, 7), Website = "https://www.charlesdickens.com", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId },
            new Author { Name = "Gabriel García Márquez", Biography = "Gabriel José de la Concordia García Márquez was a Colombian novelist, short-story writer, screenwriter, and journalist, known affectionately as Gabo throughout Latin America. Considered one of the most significant authors of the 20th century, particularly in the Spanish language, he was awarded the 1982 Nobel Prize in Literature. García Márquez is best known for his novels 'One Hundred Years of Solitude' and 'Love in the Time of Cholera', which exemplify the magical realism genre.", CountryId = colombia.Id, DateOfBirth = new DateTime(1927, 3, 6), Website = "https://www.gabrielgarciamarquez.com", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Franz Kafka", Biography = "Franz Kafka was a German-speaking Bohemian novelist and short-story writer, widely regarded as one of the major figures of 20th-century literature. His work fuses elements of realism and the fantastic. It typically features isolated protagonists facing bizarre or surrealistic predicaments and incomprehensible social-bureaucratic powers, and has been interpreted as exploring themes of alienation, existential anxiety, guilt, and absurdity.", CountryId = czech.Id, DateOfBirth = new DateTime(1883, 7, 3), Website = "https://www.franzkafka.com", PhotoUrl = "covers/franz-kafka.jpg", AuthorState = "Accepted", CreatedByUserId = adminUserId},
            new Author { Name = "Fyodor Dostoevsky", Biography = "Fyodor Mikhailovich Dostoevsky was a Russian novelist, short story writer, essayist, and journalist. Dostoevsky's literary works explore human psychology in the troubled political, social, and spiritual atmospheres of 19th-century Russia, and engage with a variety of philosophical and religious themes. His most acclaimed works include 'Crime and Punishment', 'The Idiot', 'Demons', and 'The Brothers Karamazov'. His works have had a profound influence on world literature.", CountryId = russia.Id, DateOfBirth = new DateTime(1821, 11, 11), Website = "https://www.dostoevsky.org", PhotoUrl = null, AuthorState = "Accepted", CreatedByUserId = adminUserId}
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
        new Book { Title = "1984", AuthorId = GetAuthorId("George Orwell"), Description = "Set in a dystopian future where totalitarian surveillance and thought control dominate society, '1984' follows Winston Smith, a low-ranking member of the ruling Party who begins to question the oppressive regime. As he secretly rebels against Big Brother and falls in love with Julia, Winston discovers the true extent of the Party's power and the price of resistance. This masterpiece explores themes of surveillance, propaganda, and the manipulation of truth.", PublicationYear = 1949, PageCount = 328, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Animal Farm", AuthorId = GetAuthorId("George Orwell"), Description = "A brilliant political allegory that tells the story of farm animals who overthrow their human owner and establish their own society. Initially promising equality and freedom, the revolution gradually descends into tyranny as the pigs, led by Napoleon, become increasingly corrupt and oppressive. This timeless fable explores the nature of power, corruption, and the betrayal of revolutionary ideals.", PublicationYear = 1945, PageCount = 112, CoverImagePath = "covers/animal-farm.jpg", CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Harry Potter and the Sorcerer's Stone", AuthorId = GetAuthorId("J.K. Rowling"), Description = "The magical journey begins when eleven-year-old Harry Potter discovers he is a wizard and receives an invitation to attend Hogwarts School of Witchcraft and Wizardry. As Harry learns about his mysterious past and the death of his parents, he forms friendships with Ron Weasley and Hermione Granger. Together, they uncover a plot involving the Philosopher's Stone and face the dark wizard who killed Harry's parents.", PublicationYear = 1997, PageCount = 309, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Harry Potter and the Chamber of Secrets", AuthorId = GetAuthorId("J.K. Rowling"), Description = "Harry's second year at Hogwarts becomes dangerous when students begin to be petrified by an unknown monster. The Chamber of Secrets has been opened, and Harry is suspected of being the heir of Slytherin. With the help of his friends and a mysterious diary, Harry must uncover the truth about the Chamber and save the school from the ancient evil that lurks within its walls.", PublicationYear = 1998, PageCount = 341, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Hobbit", AuthorId = GetAuthorId("J.R.R. Tolkien"), Description = "Bilbo Baggins, a respectable hobbit, is swept into an epic quest when the wizard Gandalf and thirteen dwarves arrive at his door. They seek to reclaim the Lonely Mountain and its treasure from the fearsome dragon Smaug. Along the way, Bilbo discovers courage he never knew he had, encounters trolls, goblins, elves, and a mysterious ring that will change the fate of Middle-earth forever.", PublicationYear = 1937, PageCount = 310, CoverImagePath = "covers/hobbit.jpg", CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Fellowship of the Ring", AuthorId = GetAuthorId("J.R.R. Tolkien"), Description = "The first volume of The Lord of the Rings trilogy follows Frodo Baggins as he inherits the One Ring from his uncle Bilbo. With the help of a fellowship including Gandalf, Aragorn, Legolas, Gimli, and his hobbit friends, Frodo must journey to Mount Doom to destroy the ring before the Dark Lord Sauron can reclaim it and enslave all of Middle-earth.", PublicationYear = 1954, PageCount = 423, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Pride and Prejudice", AuthorId = GetAuthorId("Jane Austen"), Description = "Set in early 19th-century England, this beloved romance follows the spirited Elizabeth Bennet as she navigates the social complexities of her time. When the proud Mr. Darcy enters her life, Elizabeth's initial prejudice against him gradually transforms into love. Through wit, humor, and social commentary, Austen explores themes of marriage, class, and the importance of understanding others beyond first impressions.", PublicationYear = 1813, PageCount = 279, CoverImagePath = "covers/pride-and-prejudice.webp", CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Emma", AuthorId = GetAuthorId("Jane Austen"), Description = "Emma Woodhouse, a wealthy and clever young woman, fancies herself a matchmaker and sets out to arrange marriages for her friends and neighbors. However, her meddling often leads to misunderstandings and complications. As Emma learns about love and relationships, she discovers that she may have been blind to her own feelings. This comedy of manners explores themes of self-deception, social class, and the complexities of human relationships.", PublicationYear = 1815, PageCount = 474, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Adventures of Huckleberry Finn", AuthorId = GetAuthorId("Mark Twain"), Description = "Huck Finn, a young boy seeking freedom from his abusive father, escapes down the Mississippi River on a raft with Jim, a runaway slave. As they encounter various characters and adventures, Huck grapples with the moral questions of slavery and society. This American classic explores themes of freedom, friendship, and the conflict between individual conscience and societal norms.", PublicationYear = 1884, PageCount = 366, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Adventures of Tom Sawyer", AuthorId = GetAuthorId("Mark Twain"), Description = "Tom Sawyer, a mischievous young boy growing up in a small town along the Mississippi River, embarks on various adventures with his friend Huck Finn. From whitewashing a fence to witnessing a murder, Tom's escapades capture the spirit of boyhood and the American frontier. This coming-of-age story explores themes of friendship, adventure, and the transition from childhood to adolescence.", PublicationYear = 1876, PageCount = 274, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Great Gatsby", AuthorId = GetAuthorId("F. Scott Fitzgerald"), Description = "Set in the Jazz Age of the 1920s, this novel follows the mysterious millionaire Jay Gatsby and his obsession with the beautiful Daisy Buchanan. Through the eyes of narrator Nick Carraway, we witness the glamour and decadence of the era, as well as the emptiness that lies beneath. This masterpiece explores themes of the American Dream, love, wealth, and the corruption of the human spirit.", PublicationYear = 1925, PageCount = 180, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "To Kill a Mockingbird", AuthorId = GetAuthorId("Harper Lee"), Description = "Through the eyes of young Scout Finch, we witness her father Atticus defending a black man falsely accused of a serious crime in 1930s Alabama. As Scout and her brother Jem navigate the complexities of race, justice, and growing up, they learn valuable lessons about empathy, courage, and the importance of standing up for what is right, even when it's difficult.", PublicationYear = 1960, PageCount = 281, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Frankenstein", AuthorId = GetAuthorId("Mary Shelley"), Description = "Victor Frankenstein, a young scientist, creates a living being from dead body parts, but is horrified by his creation and abandons it. The creature, rejected by society and seeking revenge, pursues Victor across Europe. This Gothic masterpiece explores themes of scientific ambition, the nature of humanity, the consequences of playing God, and the importance of acceptance and compassion.", PublicationYear = 1818, PageCount = 280, CoverImagePath = "covers/frankestein.webp", CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Murder on the Orient Express", AuthorId = GetAuthorId("Agatha Christie"), Description = "When a passenger is found murdered on the luxurious Orient Express, detective Hercule Poirot must solve the case before the train reaches its destination. With all passengers as suspects and a complex web of motives, Poirot uses his brilliant deductive reasoning to uncover the truth. This classic mystery explores themes of justice, revenge, and the complexity of human nature.", PublicationYear = 1934, PageCount = 256, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "A Tale of Two Cities", AuthorId = GetAuthorId("Charles Dickens"), Description = "Set against the backdrop of the French Revolution, this historical novel follows the lives of Charles Darnay, a French aristocrat, and Sydney Carton, a dissolute English lawyer, both in love with the same woman. As the revolution unfolds with its violence and chaos, themes of sacrifice, redemption, and the possibility of personal transformation emerge in this powerful tale of love and revolution.", PublicationYear = 1859, PageCount = 489, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Love in the Time of Cholera", AuthorId = GetAuthorId("Gabriel García Márquez"), Description = "Florentino Ariza falls in love with Fermina Daza when they are young, but she marries Dr. Juvenal Urbino instead. For fifty years, Florentino waits for his chance to win her back. This magical realist novel explores the nature of love, aging, and the passage of time, blending romance with social commentary and the author's signature style of magical realism.", PublicationYear = 1985, PageCount = 348, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Trial", AuthorId = GetAuthorId("Franz Kafka"), Description = "Joseph K., a bank officer, is arrested one morning for a crime that is never specified. As he navigates a labyrinthine legal system that seems designed to confuse and frustrate, Joseph struggles to understand his situation and defend himself. This existential masterpiece explores themes of alienation, the absurdity of modern life, and the individual's helplessness against bureaucratic systems.", PublicationYear = 1925, PageCount = 255, CoverImagePath = "covers/the-trial.jpeg", CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "Crime and Punishment", AuthorId = GetAuthorId("Fyodor Dostoevsky"), Description = "Rodion Raskolnikov, a poor ex-student in St. Petersburg, commits a brutal murder and then struggles with guilt, paranoia, and the psychological consequences of his crime. As he is pursued by the clever detective Porfiry, Raskolnikov's mental state deteriorates. This psychological thriller explores themes of morality, redemption, suffering, and the nature of evil.", PublicationYear = 1866, PageCount = 671, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "War and Peace", AuthorId = GetAuthorId("Leo Tolstoy"), Description = "This epic novel follows the lives of five aristocratic families during the Napoleonic Wars, particularly focusing on Pierre Bezukhov, Prince Andrei Bolkonsky, and Natasha Rostova. Through their personal struggles and the broader historical events, Tolstoy explores themes of love, war, fate, and the meaning of life. This masterpiece combines historical narrative with philosophical reflection.", PublicationYear = 1869, PageCount = 1225, CoverImagePath = "covers/war-and-peace.jpeg", CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId },
        new Book { Title = "The Old Man and the Sea", AuthorId = GetAuthorId("Ernest Hemingway"), Description = "Santiago, an aging Cuban fisherman, has gone 84 days without catching a fish. When he finally hooks a massive marlin, he engages in an epic three-day struggle with the fish and the sea. This novella explores themes of perseverance, dignity, the relationship between man and nature, and the meaning of success and failure in life.", PublicationYear = 1952, PageCount = 127, CoverImagePath = null, CreatedAt = now, UpdatedAt = now, BookState = "Accepted", CreatedByUserId = adminUserId }
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


            if (!_context.UserFriends.Any())
            {
                var testUser = _context.Users.First(u => u.Username == "testUser");
                var otherUsers = _context.Users.Where(u => u.Username != "testUser" && u.Username != "admin").Take(5).ToList();

                var friendRequests = new List<UserFriend>();

                friendRequests.Add(new UserFriend
                {
                    UserId = otherUsers[0].Id,
                    FriendId = testUser.Id,
                    Status = FriendshipStatus.Pending,
                    RequestedAt = DateTime.Now.AddDays(-2)
                });

                friendRequests.Add(new UserFriend
                {
                    UserId = testUser.Id,
                    FriendId = otherUsers[1].Id,
                    Status = FriendshipStatus.Accepted,
                    RequestedAt = DateTime.Now.AddDays(-5)
                });

                friendRequests.Add(new UserFriend
                {
                    UserId = testUser.Id,
                    FriendId = otherUsers[2].Id,
                    Status = FriendshipStatus.Accepted,
                    RequestedAt = DateTime.Now.AddDays(-3)
                });

                await _context.UserFriends.AddRangeAsync(friendRequests);
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

            // Add books to Read lists for different users
            if (!_context.ReadingListBooks.Any())
            {
                var users = _context.Users.Where(u => u.Username != "admin").Take(5).ToList();
                var books = _context.Books.Take(10).ToList();
                var readLists = _context.ReadingLists.Where(rl => rl.Name == "Read").ToList();

                var readingListBooks = new List<ReadingListBook>();
                var random = new Random();

                foreach (var user in users)
                {
                    var userReadList = readLists.First(rl => rl.UserId == user.Id);
                    var booksForUser = books.OrderBy(x => random.Next()).Take(random.Next(3, 7)).ToList();

                    foreach (var book in booksForUser)
                    {
                        readingListBooks.Add(new ReadingListBook
                        {
                            ReadingListId = userReadList.Id,
                            BookId = book.Id,
                            ReadAt = DateTime.Now.AddDays(-random.Next(1, 365)),
                        });
                    }
                }

                await _context.ReadingListBooks.AddRangeAsync(readingListBooks);
                await _context.SaveChangesAsync();
            }

            if (!_context.BookReviews.Any())
            {
                var users = _context.Users.Where(u => u.Username != "admin").Take(8).ToList();
                var books = _context.Books.Take(15).ToList();
                var random = new Random();

                var reviews = new List<BookReview>();
                var reviewTexts = new[]
                {
                    "Absolutely loved this book! The characters were so well-developed and the plot kept me engaged throughout.",
                    "A classic that lives up to its reputation. Beautiful writing and timeless themes.",
                    "Interesting concept but the execution could have been better. Still worth reading.",
                    "This book changed my perspective on life. Highly recommend to everyone.",
                    "Fast-paced and entertaining. Perfect for a weekend read.",
                    "The author's writing style is unique and captivating. Couldn't put it down.",
                    "A bit slow in the beginning but picks up nicely. Satisfying ending.",
                    "Thought-provoking and well-researched. Learned a lot from this book.",
                    "Beautiful prose and memorable characters. Will definitely read again.",
                    "A masterpiece of storytelling. The world-building is incredible."
                };

                foreach (var book in books)
                {
                    var reviewers = users.OrderBy(x => random.Next()).Take(random.Next(2, 5)).ToList();
                    foreach (var reviewer in reviewers)
                    {
                        reviews.Add(new BookReview
                        {
                            UserId = reviewer.Id,
                            BookId = book.Id,
                            Review = reviewTexts[random.Next(reviewTexts.Length)],
                                                    Rating = random.Next(3, 6), // 3-5 stars
                        isChecked = false,
                            CreatedAt = DateTime.Now.AddDays(-random.Next(1, 180))
                        });
                    }
                }

                await _context.BookReviews.AddRangeAsync(reviews);
                await _context.SaveChangesAsync();
            }

            // Add book clubs (at least 15, with 3 from testUser)
            if (!_context.BookClubs.Any())
            {
                var testUser = _context.Users.First(u => u.Username == "testUser");
                var otherUsers = _context.Users.Where(u => u.Username != "testUser" && u.Username != "admin").Take(12).ToList();
                var random = new Random();

                var bookClubs = new List<BookClub>();
                var clubNames = new[]
                {
                    "Fantasy Book Lovers", "Classic Literature Club", "Mystery & Thriller Readers",
                    "Science Fiction Enthusiasts", "Romance Novel Club", "Historical Fiction Group",
                    "Young Adult Book Club", "Contemporary Literature", "Poetry & Prose",
                    "Non-Fiction Readers", "Book Discussion Group", "Literary Classics",
                    "Modern Fiction Club", "Adventure Stories", "Philosophy & Literature"
                };

                var clubDescriptions = new[]
                {
                    "A group for fans of fantasy literature and magical worlds.",
                    "Exploring the timeless classics of world literature.",
                    "For readers who love mystery, thriller, and detective stories.",
                    "Discussing the latest in science fiction and speculative fiction.",
                    "A warm community for romance novel enthusiasts.",
                    "Exploring historical fiction and period dramas.",
                    "Young adult literature discussion and recommendations.",
                    "Contemporary fiction and modern storytelling.",
                    "Poetry, short stories, and literary prose.",
                    "Non-fiction books across various topics and genres.",
                    "General book discussion and literary analysis.",
                    "Classic literature from different eras and cultures.",
                    "Modern fiction and contemporary authors.",
                    "Adventure, action, and exciting narratives.",
                    "Philosophical literature and thought-provoking reads."
                };

                // 3 book clubs from testUser
                for (int i = 0; i < 3; i++)
                {
                    bookClubs.Add(new BookClub
                    {
                        Name = clubNames[i],
                        Description = clubDescriptions[i],
                        CreatorId = testUser.Id,
                        CreatedAt = DateTime.Now.AddDays(-random.Next(1, 30)),
                        UpdatedAt = DateTime.Now.AddDays(-random.Next(1, 30))
                    });
                }

                // 12 book clubs from other users
                for (int i = 3; i < 15; i++)
                {
                    var creator = otherUsers[i % otherUsers.Count];
                    bookClubs.Add(new BookClub
                    {
                        Name = clubNames[i],
                        Description = clubDescriptions[i],
                        CreatorId = creator.Id,
                        CreatedAt = DateTime.Now.AddDays(-random.Next(1, 60)),
                        UpdatedAt = DateTime.Now.AddDays(-random.Next(1, 60))
                    });
                }

                await _context.BookClubs.AddRangeAsync(bookClubs);
                await _context.SaveChangesAsync();
            }

            if (!_context.BookClubMembers.Any())
            {
                var testUser = _context.Users.First(u => u.Username == "testUser");
                var otherUsers = _context.Users.Where(u => u.Username != "testUser" && u.Username != "admin").Take(8).ToList();
                var allBookClubs = _context.BookClubs.ToList();
                var books = _context.Books.Take(5).ToList();
                var random = new Random();

                var bookClubMembers = new List<BookClubMember>();
                var bookClubEvents = new List<BookClubEvent>();

                foreach (var bookClub in allBookClubs)
                {
                    // Add the creator as a member 
                    bookClubMembers.Add(new BookClubMember
                    {
                        BookClubId = bookClub.Id,
                        UserId = bookClub.CreatorId,
                        JoinedAt = bookClub.CreatedAt
                    });

                    // Add 3-5 other members to each club
                    var availableUsers = otherUsers.Where(u => u.Id != bookClub.CreatorId).ToList();
                    if (availableUsers.Any())
                    {
                        var members = availableUsers.OrderBy(x => random.Next()).Take(random.Next(3, 6)).ToList();
                        foreach (var member in members)
                        {
                            bookClubMembers.Add(new BookClubMember
                            {
                                BookClubId = bookClub.Id,
                                UserId = member.Id,
                                JoinedAt = DateTime.Now.AddDays(-random.Next(1, 20))
                            });
                        }
                    }

                    // Add one event for each of testUser's book clubs only
                    if (bookClub.CreatorId == testUser.Id)
                    {
                        var eventBook = books[random.Next(books.Count)];
                        bookClubEvents.Add(new BookClubEvent
                        {
                            Title = $"Reading Discussion: {eventBook.Title}",
                            Description = $"Join us for a lively discussion about {eventBook.Title}. We'll explore themes, characters, and share our thoughts on this amazing book.",
                            BookClubId = bookClub.Id,
                            BookId = eventBook.Id,
                            CreatorId = testUser.Id,
                            Deadline = DateTime.Now.AddDays(random.Next(7, 30)),
                        });
                    }
                }

                await _context.BookClubMembers.AddRangeAsync(bookClubMembers);
                await _context.SaveChangesAsync();

                await _context.BookClubEvents.AddRangeAsync(bookClubEvents);
                await _context.SaveChangesAsync();
            }

            if (!_context.ReadingChallenges.Any())
            {
                var users = _context.Users.Where(u => u.Username != "admin").Take(8).ToList();
                var random = new Random();
                var currentYear = DateTime.Now.Year;

                var readingChallenges = new List<ReadingChallengeCreateUpdateRequest>();

                foreach (var user in users)
                {
                    for (int year = currentYear - 1; year <= currentYear; year++)
                    {
                        var goal = random.Next(12, 52); // 12-52 books goal
                        var challenge = new ReadingChallengeCreateUpdateRequest
                        {
                            UserId = user.Id,
                            Goal = goal,
                            Year = year,
                            IsCompleted = false
                        };

                        readingChallenges.Add(challenge);
                    }
                }

                // Create challenges using ReadingChallengeService
                foreach (var challengeRequest in readingChallenges)
                {
                    await _readingChallengeService.CreateAsync(challengeRequest);
                }
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