using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using BookWorm.Model.SearchObjects;
using BookWorm.Services.DataBase;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public class BookReviewService : IBookReviewService
    {
        private readonly BookWormDbContext _context;

        public BookReviewService(BookWormDbContext context)
        {
            _context = context;
        }

        public async Task<List<BookReviewResponse>> GetAsync(BookReviewSearchObject search)
        {
            var query = _context.BookReviews.Include(br => br.User).Include(br => br.Book).AsQueryable();

            if (search.UserId.HasValue)
                query = query.Where(br => br.UserId == search.UserId);
            if (search.BookId.HasValue)
                query = query.Where(br => br.BookId == search.BookId);
            if (search.Rating.HasValue)
                query = query.Where(br => br.Rating == search.Rating);
            if (search.IsChecked.HasValue)
                query = query.Where(br => br.isChecked == search.IsChecked);

            var reviews = await query.ToListAsync();
            return reviews.Select(MapToResponse).ToList();
        }

        public async Task<BookReviewResponse?> GetByIdAsync(int id)
        {
            var review = await _context.BookReviews.Include(br => br.User).Include(br => br.Book).FirstOrDefaultAsync(br => br.Id == id);
            return review != null ? MapToResponse(review) : null;
        }

        public async Task<BookReviewResponse> CreateAsync(BookReviewCreateUpdateRequest request)
        {
            var review = new BookReview
            {
                UserId = request.UserId,
                BookId = request.BookId,
                Review = request.Review,
                Rating = request.Rating,
                isChecked = request.IsChecked,
                CreatedAt = DateTime.Now
            };

            _context.BookReviews.Add(review);
            await _context.SaveChangesAsync();

            return await GetBookReviewResponseWithDetailsAsync(review.Id);
        }

        public async Task<BookReviewResponse?> UpdateAsync(int id, BookReviewCreateUpdateRequest request)
        {
            var review = await _context.BookReviews.FindAsync(id);
            if (review == null)
                return null;

            review.Review = request.Review;
            review.Rating = request.Rating;
            review.isChecked = request.IsChecked;

            await _context.SaveChangesAsync();
            return await GetBookReviewResponseWithDetailsAsync(review.Id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var review = await _context.BookReviews.FindAsync(id);
            if (review == null)
                return false;

            _context.BookReviews.Remove(review);
            await _context.SaveChangesAsync();
            return true;
        }

        private BookReviewResponse MapToResponse(BookReview review)
        {
            return new BookReviewResponse
            {
                Id = review.Id,
                UserId = review.UserId,
                UserName = review.User?.Username ?? string.Empty,
                BookId = review.BookId,
                BookTitle = review.Book?.Title ?? string.Empty,
                Review = review.Review ?? string.Empty,
                Rating = review.Rating,
                IsChecked = review.isChecked,
                CreatedAt = review.CreatedAt
            };
        }

        private async Task<BookReviewResponse> GetBookReviewResponseWithDetailsAsync(int reviewId)
        {
            var review = await _context.BookReviews.Include(br => br.User).Include(br => br.Book).FirstOrDefaultAsync(br => br.Id == reviewId);
            if (review == null)
                throw new InvalidOperationException("BookReview not found");
            return MapToResponse(review);
        }
    }
} 