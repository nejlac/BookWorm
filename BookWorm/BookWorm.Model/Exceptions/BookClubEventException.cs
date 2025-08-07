using System;

namespace BookWorm.Model.Exceptions
{
    public class BookClubEventException : Exception
    {
        public bool IsPermissionError { get; }

        public BookClubEventException(string message) : base(message)
        {
            IsPermissionError = false;
        }

        public BookClubEventException(string message, bool isPermissionError) : base(message)
        {
            IsPermissionError = isPermissionError;
        }

        public BookClubEventException(string message, Exception innerException) : base(message, innerException)
        {
            IsPermissionError = false;
        }
    }
} 