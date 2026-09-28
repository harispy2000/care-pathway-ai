using CarePathwayApi.Data;
using CarePathwayApi.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

builder.Services.AddDbContext<AppDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
    options.UseSqlServer(connectionString);
});

builder.Services.AddScoped<CarePathwayService>();

builder.Services.AddHttpClient<ICarePathwayService, GeminiCarePathwayService>(client =>
{
    client.Timeout = TimeSpan.FromSeconds(90);
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", policy =>
    {
        var origins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>();
        if (origins is { Length: > 0 })
        {
            policy.WithOrigins(origins)
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        }
        else
        {
            policy.AllowAnyOrigin()
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        }
    });
});

var app = builder.Build();

app.UseCors("AllowFlutterApp");

// If you host this API under /care in IIS/reverse proxy, uncomment this line.
// app.UsePathBase("/care");

app.MapControllers();
app.MapGet("/", () => "Care Pathway API is running");

app.Run();
