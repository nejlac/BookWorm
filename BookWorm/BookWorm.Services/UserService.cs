using BookWorm.Model.Exceptions;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class UserService : IUserService

    {
        private readonly BookWormDbContext _context;
        private const int SaltSize = 16;
        private const int KeySize = 32;
        private const int Iterations = 10000;
        private readonly ILogger<UserService> _logger;
        private readonly IReadingListService _readingListService;
        private readonly IMapper _mapper;

        public UserService(BookWormDbContext context, ILogger<UserService> logger, IReadingListService readingListService, IMapper mapper)
        {
            _context = context;
            _logger = logger;
            _readingListService = readingListService;
            _mapper = mapper;
        }

        public async Task<PagedResult<UserResponse>> GetAsync(UserSearchObject search)
        {
            var query = _context.Users.AsQueryable();

            if (!string.IsNullOrEmpty(search.Username))
            {
                query = query.Where(u => u.Username.Contains(search.Username));
            }

            if (!string.IsNullOrEmpty(search.FirstName))
            {
                query = query.Where(u => u.FirstName.Contains(search.FirstName));
            }

            if (!string.IsNullOrEmpty(search.LastName))
            {
                query = query.Where(u => u.LastName.Contains(search.LastName));
            }

            if (!string.IsNullOrEmpty(search.Email))
            {
                query = query.Where(u => u.Email.Contains(search.Email));
            }

            if (search.CountryId.HasValue)
                query = query.Where(u => u.CountryId == search.CountryId);

            if (!string.IsNullOrEmpty(search.FTS))
            {
                query = query.Where(u =>
                    u.FirstName.Contains(search.FTS) ||
                    u.LastName.Contains(search.FTS) ||
                    u.Username.Contains(search.FTS) ||
                    u.Email.Contains(search.FTS));
            }


            int? totalCount = null;
            if (search.IncludeTotalCount)
            {
                totalCount = await query.CountAsync();
            }


            if (!search.RetrieveAll)
            {
                if (search.Page.HasValue)
                {
                    query = query.Skip(search.Page.Value * search.PageSize.Value);
                }
                if (search.PageSize.HasValue)
                {
                    query = query.Take(search.PageSize.Value);
                }
            }

            var users = await query.ToListAsync();

            var userResponses = new List<UserResponse>();
            foreach (var user in users)
            {
                var userResponse = await GetUserResponseWithRolesAsync(user.Id);
                userResponses.Add(userResponse);
            }

            return new PagedResult<UserResponse>
            {
                Items = userResponses,
                TotalCount = totalCount
            };
        }

        public async Task<UserResponse?> GetByIdAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            return user != null ? MapToResponse(user) : null;
        }

        private string HashPassword(string password, out byte[] salt)
        {
            salt = new byte[SaltSize];
            using (var rng = new RNGCryptoServiceProvider()
            {

            })
            {
                rng.GetBytes(salt);
            }

            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations))
            {
                return Convert.ToBase64String(pbkdf2.GetBytes(KeySize));
            }
        }

        public async Task<UserResponse> CreateAsync(UserCreateUpdateRequest request)
        {

            if (await _context.Users.AnyAsync(u => u.Email == request.Email))
            {
                _logger.LogInformation("User is trying to register with existing email.");
                throw new UserException($"A user with the email '{request.Email}' already exists.");
            }

            if (await _context.Users.AnyAsync(u => u.Username == request.Username))
            {
                _logger.LogInformation("User is trying to register with existing username.");
                throw new UserException($"A user with the username '{request.Username}' already exists.");
            }

            var user = new User
            {
                FirstName = request.FirstName,
                LastName = request.LastName,
                Email = request.Email,
                Username = request.Username,
                PhoneNumber = request.PhoneNumber,
                IsActive = request.IsActive,
                CreatedAt = DateTime.UtcNow,
                Age = request.Age,
                CountryId = request.CountryId,
                PhotoUrl = request.PhotoUrl
            };


            if (!string.IsNullOrEmpty(request.Password))
            {
                byte[] salt;
                user.PasswordHash = HashPassword(request.Password, out salt);
                user.PasswordSalt = Convert.ToBase64String(salt);
            }


            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            // Create default reading lists for the new user
            var defaultLists = new[]
            {
                new { Name = "Want to read", Description = "Books I want to read" },
                new { Name = "Currently reading", Description = "Books I am currently reading" },
                new { Name = "Read", Description = "Books I have read" }
            };
            foreach (var list in defaultLists)
            {
                var readingListRequest = new BookWorm.Model.Requests.ReadingListCreateUpdateRequest
                {
                    UserId = user.Id,
                    Name = list.Name,
                    Description = list.Description,
                    IsPublic = true,
                    IsSystemCreated = true
                };
                await _readingListService.CreateAsync(readingListRequest);
            }

            if (request.RoleIds != null && request.RoleIds.Count > 0)
            {
                foreach (var roleId in request.RoleIds)
                {

                    if (await _context.Roles.AnyAsync(r => r.Id == roleId))
                    {
                        var userRole = new UserRole
                        {
                            UserId = user.Id,
                            RoleId = roleId,
                            DateAssigned = DateTime.UtcNow
                        };
                        _context.UserRoles.Add(userRole);
                    }
                }
                await _context.SaveChangesAsync();
            }

            return await GetUserResponseWithRolesAsync(user.Id);
        }

        public async Task<UserResponse?> UpdateAsync(int id, UserCreateUpdateRequest request)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return null;

            if (await _context.Users.AnyAsync(u => u.Email == request.Email && u.Id != id))
            {
                _logger.LogInformation("User is trying to update with existing email.");
                throw new UserException($"A user with the email '{request.Email}' already exists.");
            }

            if (await _context.Users.AnyAsync(u => u.Username == request.Username && u.Id != id))
            {
                _logger.LogInformation("User is trying to update with existing username.");
                throw new UserException($"A user with the username '{request.Username}' already exists.");
            }

            user.FirstName = request.FirstName;
            user.LastName = request.LastName;
            user.Email = request.Email;
            user.Username = request.Username;
            user.PhoneNumber = request.PhoneNumber;
            user.IsActive = request.IsActive;
            user.CountryId = request.CountryId;
            user.Age = request.Age;
            user.ModdifiedAt = DateTime.Now;
            user.PhotoUrl = request.PhotoUrl;


            if (!string.IsNullOrEmpty(request.Password))
            {
                byte[] salt;
                user.PasswordHash = HashPassword(request.Password, out salt);
                user.PasswordSalt = Convert.ToBase64String(salt);
            }


            var existingUserRoles = await _context.UserRoles.Where(ur => ur.UserId == id).ToListAsync();
            _context.UserRoles.RemoveRange(existingUserRoles);


            if (request.RoleIds != null && request.RoleIds.Count > 0)
            {
                foreach (var roleId in request.RoleIds)
                {

                    if (await _context.Roles.AnyAsync(r => r.Id == roleId))
                    {
                        var userRole = new UserRole
                        {
                            UserId = user.Id,
                            RoleId = roleId,
                            DateAssigned = DateTime.UtcNow
                        };
                        _context.UserRoles.Add(userRole);
                    }
                }
            }

            await _context.SaveChangesAsync();
            return await GetUserResponseWithRolesAsync(user.Id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return false;

            // 1. Delete all BookReviews by this user
            var reviews = _context.BookReviews.Where(r => r.UserId == id);
            _context.BookReviews.RemoveRange(reviews);

            // 2. Delete all ReadingLists (and ReadingListBooks) by this user
            var lists = _context.ReadingLists.Where(rl => rl.UserId == id).ToList();
            var listIds = lists.Select(rl => rl.Id).ToList();
            var listBooks = _context.ReadingListBooks.Where(rlb => listIds.Contains(rlb.ReadingListId));
            _context.ReadingListBooks.RemoveRange(listBooks);
            _context.ReadingLists.RemoveRange(lists);

            // 3. Delete all ReadingChallenges (and ReadingChallengeBooks) by this user
            var challenges = _context.ReadingChallenges.Where(rc => rc.UserId == id).ToList();
            var challengeIds = challenges.Select(rc => rc.Id).ToList();
            var challengeBooks = _context.ReadingChallengeBooks.Where(rcb => challengeIds.Contains(rcb.ReadingChallengeId));
            _context.ReadingChallengeBooks.RemoveRange(challengeBooks);
            _context.ReadingChallenges.RemoveRange(challenges);

            // 4. Set CreatedByUserId to null for all Books and Authors created by this user
            var books = _context.Books.Where(b => b.CreatedByUserId == id);
            foreach (var book in books)
                book.CreatedByUserId = null;
            var authors = _context.Authors.Where(a => a.CreatedByUserId == id);
            foreach (var author in authors)
                author.CreatedByUserId = null;

            // 5. Set UserId to null for all Quotes by this user (keep quotes but remove user association)
            var quotes = _context.Quotes.Where(q => q.UserId == id);
            foreach (var quote in quotes)
                quote.UserId = null;



            // 6. Remove all UserFriends where user is sender or receiver
            var sentFriends = _context.UserFriends.Where(uf => uf.UserId == id);
            var receivedFriends = _context.UserFriends.Where(uf => uf.FriendId == id);
            _context.UserFriends.RemoveRange(sentFriends);
            _context.UserFriends.RemoveRange(receivedFriends);

            // 7. Remove all UserRoles for this user
            var userRoles = _context.UserRoles.Where(ur => ur.UserId == id);
            _context.UserRoles.RemoveRange(userRoles);

            // 8. Delete all BookClubs where user is the creator
            var bookClubs = _context.BookClubs.Where(bc => bc.CreatorId == id).ToList();
            _context.BookClubs.RemoveRange(bookClubs);

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();
            return true;
        }

        private UserResponse MapToResponse(User user)
        {
            return new UserResponse
            {
                Id = user.Id,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Email = user.Email,
                Username = user.Username,
                PhoneNumber = user.PhoneNumber,
                IsActive = user.IsActive,
                CreatedAt = user.CreatedAt,
                LastLoginAt = user.LastLoginAt,
                CountryId = user.CountryId,
                Age = user.Age,
                PhotoUrl = user.PhotoUrl,


            };
        }


        private async Task<UserResponse> GetUserResponseWithRolesAsync(int userId)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
                throw new UserException("User not found");

            var response = MapToResponse(user);

            response.Roles = user.UserRoles
                .Where(ur => ur.Role.IsActive)
                .Select(ur => new RoleResponse
                {
                    Id = ur.Role.Id,
                    Name = ur.Role.Name,
                    Description = ur.Role.Description
                })
                .ToList();

            return response;
        }

        public async Task<UserResponse?> AuthenticateAsync(UserLoginRequest request)
        {
            var user = await _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefaultAsync(u => u.Username == request.Username);

            if (user == null)
                return null;

            if (!VerifyPassword(request.Password!, user.PasswordHash, user.PasswordSalt))
                return null;


            user.LastLoginAt = DateTime.Now;
            await _context.SaveChangesAsync();

            var response = MapToResponse(user);

            response.Roles = user.UserRoles
                .Where(ur => ur.Role.IsActive)
                .Select(ur => new RoleResponse
                {
                    Id = ur.Role.Id,
                    Name = ur.Role.Name,
                    Description = ur.Role.Description
                })
                .ToList();

            return response;
        }
        private bool VerifyPassword(string password, string passwordHash, string passwordSalt)
        {
            var salt = Convert.FromBase64String(passwordSalt);
            var hash = Convert.FromBase64String(passwordHash);
            var hashBytes = new Rfc2898DeriveBytes(password, salt, Iterations).GetBytes(KeySize);
            return hash.SequenceEqual(hashBytes);
        }

        // --- STATISTICS METHODS ---
        public async Task<int> GetUsersCount()
        {
            return await _context.Users.CountAsync();
        }

        public async Task<List<AgeDistributionResponse>> GetUserAgeDistribution()
        {
            
            var ageGroups = new List<(int? min, int? max, string label)>
            {
                (13, 16, "13-16"),
                (17, 19, "17-19"),
                (20, 24, "20-24"),
                (25, 30, "25-30"),
                (31, 35, "31-35"),
                (36, 40, "36-40"),
                (41, 45, "41-45"),
                (46, 50, "46-50"),
                (51, 55, "51-55"),
                (56, 60, "56-60"),
                (61, null, ">60")
            };

            var users = await _context.Users.ToListAsync();
            var result = ageGroups.Select(g => new AgeDistributionResponse
            {
                AgeRange = g.label,
                Count = users.Count(u => (!g.min.HasValue || u.Age >= g.min) && (!g.max.HasValue || u.Age <= g.max))
            }).ToList();
            return result;
        }

        public async Task<List<GenreStatisticResponse>> GetUserMostReadGenres(int userId, int? year = null)
        {
            var query = _context.ReadingListBooks
                .Include(rlb => rlb.ReadingList)
                .Include(rlb => rlb.Book)
                .ThenInclude(b => b.BookGenres)
                .ThenInclude(bg => bg.Genre)
                .Where(rlb => rlb.ReadingList.UserId == userId && 
                             rlb.ReadingList.Name.ToLower() == "read" &&
                             rlb.ReadAt != null);

            if (year.HasValue)
            {
                query = query.Where(rlb => rlb.ReadAt.Value.Year == year.Value);
            }

            var readBooks = await query.ToListAsync();

            var genreCounts = new Dictionary<string, int>();
            var totalBooks = 0;

            foreach (var readBook in readBooks)
            {
                if (readBook.Book?.BookGenres != null)
                {
                    foreach (var bookGenre in readBook.Book.BookGenres)
                    {
                        var genreName = bookGenre.Genre.Name;
                        if (!genreCounts.ContainsKey(genreName))
                        {
                            genreCounts[genreName] = 0;
                        }
                        genreCounts[genreName]++;
                        totalBooks++;
                    }
                }
            }

            if (totalBooks == 0)
            {
                return new List<GenreStatisticResponse>();
            }

            var result = genreCounts
                .OrderByDescending(x => x.Value)
                .Take(5)
                .Select(x => new GenreStatisticResponse
                {
                    GenreName = x.Key,
                    Percentage = Math.Round((double)x.Value / totalBooks * 100, 1)
                })
                .ToList();

            return result;
        }

        public async Task<UserRatingStatisticsResponse> GetUserRatingStatistics(int userId, int? year = null)
        {
            var query = _context.BookReviews
                .Include(br => br.Book)
                .Where(br => br.UserId == userId);

            if (year.HasValue)
            {
                query = query.Where(br => br.CreatedAt.Year == year.Value);
            }

            var reviews = await query.ToListAsync();

            if (!reviews.Any())
            {
                return new UserRatingStatisticsResponse
                {
                    AverageRating = 0,
                    TotalReviews = 0,
                    RatingDistribution = new Dictionary<double, int>
                    {
                        { 1.0, 0 }, { 1.5, 0 }, { 2.0, 0 }, { 2.5, 0 },
                        { 3.0, 0 }, { 3.5, 0 }, { 4.0, 0 }, { 4.5, 0 }, { 5.0, 0 }
                    }
                };
            }

            var averageRating = Math.Round(reviews.Average(r => r.Rating), 1);
            var totalReviews = reviews.Count;

            var ratingDistribution = new Dictionary<double, int>
            {
                { 1.0, 0 }, { 1.5, 0 }, { 2.0, 0 }, { 2.5, 0 },
                { 3.0, 0 }, { 3.5, 0 }, { 4.0, 0 }, { 4.5, 0 }, { 5.0, 0 }
            };

            foreach (var review in reviews)
            {
                if (ratingDistribution.ContainsKey(review.Rating))
                {
                    ratingDistribution[review.Rating]++;
                }
            }

            return new UserRatingStatisticsResponse
            {
                AverageRating = averageRating,
                TotalReviews = totalReviews,
                RatingDistribution = ratingDistribution
            };
        }
        public async Task<List<UserResponse>> RecommendFriends(int userId)
        {
            var mlContext = new MLContext();

            var userReadMap = await _context.ReadingLists
                .Where(rl => rl.Name == "Read")
                .Include(rl => rl.ReadingListBooks)
                .ToListAsync();

            var data = new List<UserBookEntry>();

            foreach (var list in userReadMap)
            {
                var distinctBookIds = list.ReadingListBooks.Select(r => r.BookId).Distinct().ToList();

                foreach (var bookId in distinctBookIds)
                {
                    foreach (var otherBookId in distinctBookIds.Where(id => id != bookId))
                    {
                        data.Add(new UserBookEntry
                        {
                            UserId = (uint)list.UserId,
                            BookId = (uint)bookId,
                            Label = 1f
                        });
                    }
                }
            }

            if (data.Count == 0)
            {
                // if there are no books read by current user, fallback to most active users
                return await GetMostActiveUsersFallback(userId);
            }

            ITransformer? model = null ;
var modelPath = "ml_friend_model.zip";
bool retrainModel = true;

if (File.Exists(modelPath))
{
    var lastWriteTime = File.GetLastWriteTime(modelPath);
    if ((DateTime.Now - lastWriteTime).TotalDays < 1)
    {
        using var fileStream = new FileStream(modelPath, FileMode.Open, FileAccess.Read, FileShare.Read);
        model = mlContext.Model.Load(fileStream, out var _);
        retrainModel = false;
    }
}

if (retrainModel)
{
            var trainData = mlContext.Data.LoadFromEnumerable(data);

            var options = new MatrixFactorizationTrainer.Options
            {
                MatrixColumnIndexColumnName = nameof(UserBookEntry.BookId),
                MatrixRowIndexColumnName = nameof(UserBookEntry.UserId),
                LabelColumnName = nameof(UserBookEntry.Label),
                LossFunction = MatrixFactorizationTrainer.LossFunctionType.SquareLossOneClass,
                Alpha = 0.01,
                Lambda = 0.1,
                NumberOfIterations = 40,
                C = 0.0001
            };

            var estimator = mlContext.Recommendation().Trainers.MatrixFactorization(options);
    model = estimator.Fit(trainData);

    using var fileStream = new FileStream(modelPath, FileMode.Create, FileAccess.Write, FileShare.Write);
    mlContext.Model.Save(model, trainData.Schema, fileStream);
}


            // Get users who are already friends with the current user (either as sender or receiver)
            var existingFriendships = await _context.UserFriends
                .Where(uf => (uf.UserId == userId || uf.FriendId == userId) && uf.Status == FriendshipStatus.Accepted)
                .Select(uf => uf.UserId == userId ? uf.FriendId : uf.UserId)
                .Distinct()
                .ToListAsync();

            var allUserIds = userReadMap
                .Select(rl => rl.UserId)
                .Distinct()
                .Where(uid => uid != userId && !existingFriendships.Contains(uid))
                .ToList();



            var predictionEngine = mlContext.Model.CreatePredictionEngine<UserBookEntry, FriendPrediction>(model!);

            var scores = new List<(int otherUserId, float score)>();

            foreach (var otherUserId in allUserIds)
            {
                var score = 0f;

                var sharedBooks = userReadMap
                    .Where(rl => rl.UserId == userId)
                    .SelectMany(rl => rl.ReadingListBooks.Select(rb => rb.BookId))
                    .Distinct()
                    .ToList();

                foreach (var bookId in sharedBooks)
                {
                    var prediction = predictionEngine.Predict(new UserBookEntry
                    {
                        UserId = (uint)userId,
                        BookId = (uint)bookId
                    });

                    score += prediction.Score;
                }

                scores.Add((otherUserId, score));
            }

            var topUserIds = scores
                .OrderByDescending(x => x.score)
                .Select(x => x.otherUserId)
                .Distinct()
                .Take(10)
                .ToList();

            if (!topUserIds.Any())
            {
                return await GetMostActiveUsersFallback(userId);
            }

            var users = await _context.Users
                .Where(u => topUserIds.Contains(u.Id))
                .ToListAsync();

            return _mapper.Map<List<UserResponse>>(users);
        }

        private async Task<List<UserResponse>> GetMostActiveUsersFallback(int excludeUserId)
        {
            // Get users who are already friends with the current user
            var existingFriendships = await _context.UserFriends
                .Where(uf => (uf.UserId == excludeUserId || uf.FriendId == excludeUserId) && uf.Status == FriendshipStatus.Accepted)
                .Select(uf => uf.UserId == excludeUserId ? uf.FriendId : uf.UserId)
                .Distinct()
                .ToListAsync();

            var mostActive = await _context.ReadingLists
                .Where(rl => rl.Name == "Read" && rl.UserId != excludeUserId && !existingFriendships.Contains(rl.UserId))
                .GroupBy(rl => rl.UserId)
                .Select(group => new
                {
                    UserId = group.Key,
                    Total = group.SelectMany(g => g.ReadingListBooks).Count()
                })
                .OrderByDescending(g => g.Total)
                .Take(10)
                .ToListAsync();

            var userIds = mostActive.Select(x => x.UserId).ToList();

            var users = await _context.Users
                .Where(u => userIds.Contains(u.Id))
                .ToListAsync();

            return _mapper.Map<List<UserResponse>>(users);
        }
        public class UserBookEntry
        {
            [KeyType(count: 1000)]
            public uint UserId { get; set; }

            [KeyType(count: 1000)]
            public uint BookId { get; set; }

            public float Label { get; set; }
        }

        public class FriendPrediction
        {
            public float Score { get; set; }
        }


    }

}