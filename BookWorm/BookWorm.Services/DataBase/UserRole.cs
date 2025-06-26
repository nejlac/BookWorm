﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BookWorm.Services.DataBase
{
    public class UserRole
    {
        [Key]
        public int Id { get; set; }

     
        public int UserId { get; set; }

        [ForeignKey("UserId")]
        public User User { get; set; } = null!;

   
        public int RoleId { get; set; }

        [ForeignKey("RoleId")]
        public Role Role { get; set; } = null!;

        public DateTime DateAssigned { get; set; } = DateTime.Now;
    }
}
