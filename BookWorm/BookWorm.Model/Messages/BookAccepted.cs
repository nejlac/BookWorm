using BookWorm.Model.Responses;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Model.Messages
{
    public class BookAccepted
    {
        public BookResponse Book { get; set; }
    }
}
