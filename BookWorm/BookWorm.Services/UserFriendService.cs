using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BookWorm.Model.Exceptions;

namespace BookWorm.Services
{
    public class UserFriendService : BaseCRUDService<UserFriendResponse, UserFriendSearchObject, UserFriend, UserFriendRequest, UserFriendRequest>, IUserFriendService
    {
        private readonly BookWormDbContext _context;
        private readonly ILogger<UserFriendService> _logger;

        public UserFriendService(BookWormDbContext context, IMapper mapper, ILogger<UserFriendService> logger) : base(context, mapper)
        {
            _context = context;
            _logger = logger;
        }

        protected override IQueryable<UserFriend> ApplyFilter(IQueryable<UserFriend> query, UserFriendSearchObject search)
        {
            if (search.UserId.HasValue)
                query = query.Where(uf => uf.UserId == search.UserId);
            if (search.FriendId.HasValue)
                query = query.Where(uf => uf.FriendId == search.FriendId);
            if (search.Status.HasValue)
                query = query.Where(uf => (int)uf.Status == search.Status);

            query = query.Include(uf => uf.User).Include(uf => uf.Friend);
            return query;
        }

        protected override UserFriendResponse MapToResponse(UserFriend entity)
        {
            return new UserFriendResponse
            {
                Id = entity.Id,
                UserId = entity.UserId,
                UserName = entity.User?.Username ?? string.Empty,
                UserPhotoUrl = entity.User?.PhotoUrl ?? string.Empty,
                FriendId = entity.FriendId,
                FriendName = entity.Friend?.Username ?? string.Empty,
                FriendPhotoUrl = entity.Friend?.PhotoUrl ?? string.Empty,
                Status = (int)entity.Status,
                RequestedAt = entity.RequestedAt
            };
        }

        protected override async Task BeforeInsert(UserFriend entity, UserFriendRequest request)
        {
           
            var user = await _context.Users.FindAsync(request.UserId);
            var friend = await _context.Users.FindAsync(request.FriendId);
            
            if (user == null || friend == null)
            {
                throw new Exception("User or friend not found.");
            }

            if (request.UserId == request.FriendId)
            {
                throw new Exception("Cannot add yourself as a friend.");
            }

            var existingFriendship = await _context.UserFriends
                .FirstOrDefaultAsync(uf => 
                    (uf.UserId == request.UserId && uf.FriendId == request.FriendId) ||
                    (uf.UserId == request.FriendId && uf.FriendId == request.UserId));

            if (existingFriendship != null)
            {
                throw new Exception("Friendship request already exists.");
            }

            entity.UserId = request.UserId;
            entity.FriendId = request.FriendId;
            entity.Status = FriendshipStatus.Pending;
            entity.RequestedAt = DateTime.Now;
        }

        public async Task<UserFriendResponse> SendFriendRequestAsync(UserFriendRequest request)
        {
            
            var existingFriendship = await _context.UserFriends
                .FirstOrDefaultAsync(uf => 
                    (uf.UserId == request.UserId && uf.FriendId == request.FriendId) ||
                    (uf.UserId == request.FriendId && uf.FriendId == request.UserId));

            if (existingFriendship != null)
            {
                
                existingFriendship.Status = FriendshipStatus.Pending;
                existingFriendship.RequestedAt = DateTime.Now;
                await _context.SaveChangesAsync();
                return MapToResponse(existingFriendship);
            }

            // If no existing friendship, create a new one
            return await CreateAsync(request);
        }

        public async Task<UserFriendResponse?> UpdateFriendshipStatusAsync(UpdateFriendshipStatusRequest request)
        {
            var friendship = await _context.UserFriends
                .FirstOrDefaultAsync(uf => 
                    (uf.UserId == request.UserId && uf.FriendId == request.FriendId) ||
                    (uf.UserId == request.FriendId && uf.FriendId == request.UserId));

            if (friendship == null)
            {
                throw new Exception("Friendship not found.");
            }

            if (friendship.FriendId != request.UserId)
            {
                throw new Exception("Only the recipient can update the friendship status.");
            }

            friendship.Status = (FriendshipStatus)request.Status;
            await _context.SaveChangesAsync();

            return MapToResponse(friendship);
        }

        public async Task<List<UserFriendResponse>> GetUserFriendsAsync(int userId)
        {
            var friendships = await _context.UserFriends
                .Include(uf => uf.User)
                .Include(uf => uf.Friend)
                .Where(uf => (uf.UserId == userId || uf.FriendId == userId) && uf.Status == FriendshipStatus.Accepted)
                .ToListAsync();

            return friendships.Select(MapToResponse).ToList();
        }

        public async Task<List<UserFriendResponse>> GetPendingFriendRequestsAsync(int userId)
        {
            var pendingRequests = await _context.UserFriends
                .Include(uf => uf.User)
                .Include(uf => uf.Friend)
                .Where(uf => uf.FriendId == userId && uf.Status == FriendshipStatus.Pending)
                .ToListAsync();

            return pendingRequests.Select(MapToResponse).ToList();
        }

        public async Task<List<UserFriendResponse>> GetSentFriendRequestsAsync(int userId)
        {
            var sentRequests = await _context.UserFriends
                .Include(uf => uf.User)
                .Include(uf => uf.Friend)
                .Where(uf => uf.UserId == userId && uf.Status == FriendshipStatus.Pending)
                .ToListAsync();

            return sentRequests.Select(MapToResponse).ToList();
        }

        public async Task<FriendshipStatusResponse?> GetFriendshipStatusAsync(int userId, int friendId)
        {
            var friendship = await _context.UserFriends
                .FirstOrDefaultAsync(uf => 
                    (uf.UserId == userId && uf.FriendId == friendId) ||
                    (uf.UserId == friendId && uf.FriendId == userId));

            if (friendship == null)
                return null;

            return new FriendshipStatusResponse
            {
                UserId = friendship.UserId,
                FriendId = friendship.FriendId,
                Status = (int)friendship.Status,
                RequestedAt = friendship.RequestedAt
            };
        }

        public async Task<bool> RemoveFriendAsync(int userId, int friendId)
        {
            var friendship = await _context.UserFriends
                .FirstOrDefaultAsync(uf => 
                    (uf.UserId == userId && uf.FriendId == friendId) ||
                    (uf.UserId == friendId && uf.FriendId == userId));

            if (friendship == null)
                return false;

            _context.UserFriends.Remove(friendship);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<bool> CancelFriendRequestAsync(int userId, int friendId)
        {
            var friendship = await _context.UserFriends
                .FirstOrDefaultAsync(uf => 
                    uf.UserId == userId && uf.FriendId == friendId && uf.Status == FriendshipStatus.Pending);

            if (friendship == null)
                return false;

            _context.UserFriends.Remove(friendship);
            await _context.SaveChangesAsync();
            return true;
        }
    }
} 