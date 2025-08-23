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
        config.AddEnvironmentVariables();
    })
    .Build();

Console.WriteLine("📚 BookWorm Subscriber started...");



var emailSettings = new EmailSettings
{
    FromEmail = Environment.GetEnvironmentVariable("EmailSettings__FromEmail") ?? "",
    SmtpServer = Environment.GetEnvironmentVariable("EmailSettings__SmtpServer") ?? "",
    Port = int.TryParse(Environment.GetEnvironmentVariable("EmailSettings__Port"), out int port) ? port : 587,
    Password = Environment.GetEnvironmentVariable("EmailSettings__Password") ?? ""
};

// Read RabbitMQ settings from environment variables
var rabbitMqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost";
var rabbitMqUser = Environment.GetEnvironmentVariable("RABBITMQ_USER") ?? "guest";
var rabbitMqPassword = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest";

Console.WriteLine($"Connecting to RabbitMQ at: {rabbitMqHost}");

// Create RabbitMQ connection string with credentials
var connectionString = $"host={rabbitMqHost};username={rabbitMqUser};password={rabbitMqPassword}";

IBus bus;
try
{
    bus = RabbitHutch.CreateBus(connectionString);
    Console.WriteLine("✅ Successfully connected to RabbitMQ");
}
catch (Exception ex)
{
    Console.WriteLine($"❌ Failed to connect to RabbitMQ: {ex.Message}");
    Console.WriteLine("Retrying in 5 seconds...");
    await Task.Delay(5000);
    
    try
    {
        bus = RabbitHutch.CreateBus(connectionString);
        Console.WriteLine("✅ Successfully connected to RabbitMQ on retry");
    }
    catch (Exception retryEx)
    {
        Console.WriteLine($"❌ Failed to connect to RabbitMQ on retry: {retryEx.Message}");
        return;
    }
}

Console.WriteLine("Setting up subscription for BookAccepted messages...");

try
{
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
    
    Console.WriteLine("✅ Successfully subscribed to BookAccepted messages");
}
catch (Exception ex)
{
    Console.WriteLine($"❌ Failed to subscribe to messages: {ex.Message}");
    return;
}

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
    Console.WriteLine("Service is shutting down...");
}
