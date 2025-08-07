using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace BookWormWebAPI.Migrations
{
    /// <inheritdoc />
    public partial class bookClubs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BookClubs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    CreatorId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BookClubs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BookClubs_Users_CreatorId",
                        column: x => x.CreatorId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "BookClubEvents",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Deadline = table.Column<DateTime>(type: "datetime2", nullable: false),
                    BookId = table.Column<int>(type: "int", nullable: false),
                    BookClubId = table.Column<int>(type: "int", nullable: false),
                    CreatorId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BookClubEvents", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BookClubEvents_BookClubs_BookClubId",
                        column: x => x.BookClubId,
                        principalTable: "BookClubs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BookClubEvents_Books_BookId",
                        column: x => x.BookId,
                        principalTable: "Books",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_BookClubEvents_Users_CreatorId",
                        column: x => x.CreatorId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "BookClubMembers",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    BookClubId = table.Column<int>(type: "int", nullable: false),
                    JoinedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BookClubMembers", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BookClubMembers_BookClubs_BookClubId",
                        column: x => x.BookClubId,
                        principalTable: "BookClubs",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BookClubMembers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "BookClubEventParticipants",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    BookClubEventId = table.Column<int>(type: "int", nullable: false),
                    IsCompleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BookClubEventParticipants", x => x.Id);
                    table.ForeignKey(
                        name: "FK_BookClubEventParticipants_BookClubEvents_BookClubEventId",
                        column: x => x.BookClubEventId,
                        principalTable: "BookClubEvents",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_BookClubEventParticipants_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_BookClubEventParticipants_BookClubEventId",
                table: "BookClubEventParticipants",
                column: "BookClubEventId");

            migrationBuilder.CreateIndex(
                name: "IX_BookClubEventParticipants_UserId_BookClubEventId",
                table: "BookClubEventParticipants",
                columns: new[] { "UserId", "BookClubEventId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_BookClubEvents_BookClubId",
                table: "BookClubEvents",
                column: "BookClubId");

            migrationBuilder.CreateIndex(
                name: "IX_BookClubEvents_BookId",
                table: "BookClubEvents",
                column: "BookId");

            migrationBuilder.CreateIndex(
                name: "IX_BookClubEvents_CreatorId",
                table: "BookClubEvents",
                column: "CreatorId");

            migrationBuilder.CreateIndex(
                name: "IX_BookClubMembers_BookClubId",
                table: "BookClubMembers",
                column: "BookClubId");

            migrationBuilder.CreateIndex(
                name: "IX_BookClubMembers_UserId_BookClubId",
                table: "BookClubMembers",
                columns: new[] { "UserId", "BookClubId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_BookClubs_CreatorId",
                table: "BookClubs",
                column: "CreatorId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BookClubEventParticipants");

            migrationBuilder.DropTable(
                name: "BookClubMembers");

            migrationBuilder.DropTable(
                name: "BookClubEvents");

            migrationBuilder.DropTable(
                name: "BookClubs");
        }
    }
}
