using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Exceptions
{
    public class BookException : Exception
    {
        public bool IsPermissionError { get; }

        public BookException(string message) : base(message)
        {
            IsPermissionError = false;
        }

        public BookException(string message, bool isPermissionError) : base(message)
        {
            IsPermissionError = isPermissionError;
        }

        public BookException(string message, Exception inner) : base(message, inner) { }
    }
}
