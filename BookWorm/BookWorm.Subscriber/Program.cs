using BookWorm.Model.Messages;
using EasyNetQ;
using MailKit.Net.Smtp;
using MimeKit;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;


var host = Host.CreateDefaultBuilder(args)
    .ConfigureAppConfiguration((context, config) =>
    {
        config.AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
        config.AddEnvironmentVariables();
    })
    .ConfigureServices((context, services) =>
    {
        services.Configure<EmailSettings>(context.Configuration.GetSection("EmailSettings"));
    })
    .Build();

var config = host.Services.GetRequiredService<IConfiguration>();
var emailSettings = config.GetSection("EmailSettings").Get<EmailSettings>();

Console.WriteLine("📚 BookWorm Subscriber started...");

var rabbitMqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
Console.WriteLine($"Connecting to RabbitMQ at: {rabbitMqHost}");

var bus = RabbitHutch.CreateBus($"host={rabbitMqHost}");
Console.WriteLine("✅ Successfully connected to RabbitMQ");

Console.WriteLine("Setting up subscription for BookAccepted messages...");
await bus.PubSub.SubscribeAsync<BookAccepted>("book_accepted_email_sender", async msg =>
{
    try
    {
        Console.WriteLine($"Received message: {msg.Book?.Title ?? "Unknown book"}");
        
        var book = msg.Book;
        var user = book?.CreatedByUser;

        if (user == null)
        {
            Console.WriteLine($"User not found for book: {book?.Title ?? "Unknown"}");
            return;
        }

        Console.WriteLine($"Processing book approval: {book.Title} by {user.FirstName} {user.LastName}");

        var emailMessage = new MimeMessage();
        emailMessage.From.Add(MailboxAddress.Parse(emailSettings.FromEmail));
        emailMessage.To.Add(MailboxAddress.Parse(user.Email));
        emailMessage.Subject = "Your book has been approved!";
        emailMessage.Body = new TextPart("plain")
        {
            Text = $"Hi {user.FirstName},\n\nYour book \"{book.Title}\" has been approved and is now visible on the platform.\n\nThanks for contributing!\n- BookWorm Team"
        };

        Console.WriteLine($"Attempting to send email to {user.Email} via {emailSettings.SmtpServer}:{emailSettings.Port}");

        using var smtp = new SmtpClient();
        await smtp.ConnectAsync(emailSettings.SmtpServer, emailSettings.Port, MailKit.Security.SecureSocketOptions.StartTls);
        await smtp.AuthenticateAsync(emailSettings.FromEmail, emailSettings.Password);
        await smtp.SendAsync(emailMessage);
        await smtp.DisconnectAsync(true);

        Console.WriteLine($"✅ Email sent successfully to {user.Email}");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error processing message: {ex.Message}");
        Console.WriteLine($"Stack trace: {ex.StackTrace}");
    }
});

Console.WriteLine(" Listening for messages... Press any key to exit.");
var cts = new CancellationTokenSource();
Console.CancelKeyPress += (sender, e) => {
    e.Cancel = true;
    cts.Cancel();
};

try
{
    await Task.Delay(-1, cts.Token);
}
catch (TaskCanceledException)
{
    Console.WriteLine("Service is shutting down...");
}
