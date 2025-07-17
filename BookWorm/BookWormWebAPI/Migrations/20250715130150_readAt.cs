using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BookWormWebAPI.Migrations
{
    /// <inheritdoc />
    public partial class readAt : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ReadAt",
                table: "ReadingListBooks",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Review",
                table: "BookReviews",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(2000)",
                oldMaxLength: 2000);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ReadAt",
                table: "ReadingListBooks");

            migrationBuilder.AlterColumn<string>(
                name: "Review",
                table: "BookReviews",
                type: "nvarchar(2000)",
                maxLength: 2000,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(2000)",
                oldMaxLength: 2000,
                oldNullable: true);
        }
    }
}
