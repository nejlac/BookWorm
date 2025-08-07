using System;

namespace BookWorm.Model.Exceptions
{
    public class BookClubException : Exception
    {
        public bool IsPermissionError { get; }

        public BookClubException(string message) : base(message)
        {
            IsPermissionError = false;
        }

        public BookClubException(string message, bool isPermissionError) : base(message)
        {
            IsPermissionError = isPermissionError;
        }

        public BookClubException(string message, Exception innerException) : base(message, innerException)
        {
            IsPermissionError = false;
        }
    }
} 