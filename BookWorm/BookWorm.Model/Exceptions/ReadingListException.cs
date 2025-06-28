using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Exceptions
{
    public class ReadingListException : Exception
    {
        public ReadingListException(string message) : base(message) { }
        public ReadingListException(string message, Exception inner) : base(message, inner) { }
    }
}
