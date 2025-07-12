using BookWorm.Services;
using BookWorm.Services.AuthorStateMachine;
using BookWorm.Services.BookStateMachine;
using BookWorm.Services.DataBase;
using BookWormWebAPI.Filters;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IBookService, BookService>();
builder.Services.AddTransient<IReadingListService, ReadingListService>();
builder.Services.AddTransient<IAuthorService, AuthorService>();
builder.Services.AddTransient<IBookReviewService, BookReviewService>();
builder.Services.AddTransient<IReadingChallengeService, ReadingChallengeService>();
builder.Services.AddTransient<IUserRoleService, UserRoleService>();
builder.Services.AddScoped<IGenreService, GenreService>();
builder.Services.AddScoped<ICountryService, CountryService>();
builder.Services.AddScoped<IRoleService, RoleService>();

builder.Services.AddHttpContextAccessor();

builder.Services.AddTransient<BaseBookState>();
builder.Services.AddTransient<SubmittedBookState>();
builder.Services.AddTransient<AcceptedBookState>();
builder.Services.AddTransient<DeclinedBookState>();
builder.Services.AddTransient<BaseAuthorState>();
builder.Services.AddTransient<SubmittedAuthorState>();
builder.Services.AddTransient<AcceptedAuthorState>();
builder.Services.AddTransient<DeclinedAuthorState>();


builder.Services.AddMapster();

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();


builder.Services.AddDbContext<BookWormDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"), 
        b => b.MigrationsAssembly("BookWormWebAPI")));
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("BasicAuthentication", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Bearer scheme."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "BasicAuthentication" } },
            new string[] { }
        }
    });
});


var app = builder.Build();


try
{
    using (var scope = app.Services.CreateScope())
    {
        var context = scope.ServiceProvider.GetRequiredService<BookWormDbContext>();
        context.Database.EnsureCreated();
        Console.WriteLine("Database connection successful and database created/verified.");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Database connection failed: {ex.Message}");
    Console.WriteLine($"Connection string: {builder.Configuration.GetConnectionString("DefaultConnection")}");
    throw;
}


if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
    
app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.UseStaticFiles();

app.MapControllers();

app.Run();
