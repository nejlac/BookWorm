using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BookWormWebAPI.Migrations
{
    /// <inheritdoc />
    public partial class challengeUpdated : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "isCompleted",
                table: "ReadingChallenges",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "isCompleted",
                table: "ReadingChallenges");
        }
    }
}
