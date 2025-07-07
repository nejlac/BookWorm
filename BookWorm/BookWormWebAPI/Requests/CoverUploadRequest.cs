using Microsoft.AspNetCore.Http;

namespace BookWormWebAPI.Requests
{
    public class CoverUploadRequest
    {
        public IFormFile? CoverImage { get; set; }
    }
} 