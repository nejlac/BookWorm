using BookWorm.Model.SearchObjects;
using BookWorm.Model.Requests;
using BookWorm.Model.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services
{
    public interface IService
    {
        public interface IService<T, TSearch> where T : class where TSearch : BaseSearchObject
        {
            Task<PagedResult<T>> GetAsync(TSearch search);
            Task<T?> GetByIdAsync(int id);
        }
    }
}
