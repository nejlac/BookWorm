using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Exceptions
{
    public class QuoteException : Exception
    {
        public QuoteException(string message) : base(message)
        {
        }

        public QuoteException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
} 