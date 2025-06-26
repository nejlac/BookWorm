using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BookWormWebAPI.Migrations
{
    /// <inheritdoc />
    public partial class challengeUpdated1 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "isCompleted",
                table: "ReadingChallenges",
                newName: "IsCompleted");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "IsCompleted",
                table: "ReadingChallenges",
                newName: "isCompleted");
        }
    }
}
