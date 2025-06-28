using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Exceptions
{
    public class AuthorException : Exception
    {
        public AuthorException(string message) : base(message) { }
        public AuthorException(string message, Exception inner) : base(message, inner) { }
    }
}
