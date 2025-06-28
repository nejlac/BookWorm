using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Exceptions
{
    public class BookReviewException : Exception
    {
        public BookReviewException(string message) : base(message) { }
        public BookReviewException(string message, Exception inner) : base(message, inner) { }
    }
}