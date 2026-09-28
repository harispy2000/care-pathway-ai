using CarePathwayApi.Data;
using CarePathwayApi.Entities;
using CarePathwayApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CarePathwayApi.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _db;

    public AuthController(AppDbContext db)
    {
        _db = db;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register(AuthRegisterRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.FullName) ||
            string.IsNullOrWhiteSpace(request.Email) ||
            string.IsNullOrWhiteSpace(request.Password))
        {
            return BadRequest("Full name, email and password are required.");
        }

        var email = request.Email.Trim().ToLowerInvariant();

        var exists = await _db.AppUsers.AnyAsync(x => x.Email == email);
        if (exists)
        {
            return BadRequest("Email already exists.");
        }

        var user = new AppUser
        {
            FullName = request.FullName.Trim(),
            Email = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            Role = "Patient"
        };

        _db.AppUsers.Add(user);
        await _db.SaveChangesAsync();

        return Ok(ToResponse(user));
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(AuthLoginRequest request)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var user = await _db.AppUsers.FirstOrDefaultAsync(x => x.Email == email);
        if (user == null)
        {
            return Unauthorized("Invalid email or password.");
        }

        var isValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
        if (!isValid)
        {
            return Unauthorized("Invalid email or password.");
        }

        return Ok(ToResponse(user));
    }

    [HttpPost("save-fcm-token")]
    public async Task<IActionResult> SaveFcmToken(SaveFcmTokenRequest request)
    {
        if (request.UserId <= 0)
        {
            return BadRequest("Invalid user id.");
        }

        if (string.IsNullOrWhiteSpace(request.FcmToken))
        {
            return BadRequest("FCM token is required.");
        }

        var user = await _db.AppUsers.FirstOrDefaultAsync(x => x.Id == request.UserId);
        if (user == null)
        {
            return NotFound("User not found.");
        }

        user.FcmToken = request.FcmToken;
        await _db.SaveChangesAsync();

        return Ok(new { message = "FCM token saved successfully" });
    }

    private static AuthUserResponse ToResponse(AppUser user)
    {
        return new AuthUserResponse
        {
            UserId = user.Id,
            FullName = user.FullName,
            Email = user.Email,
            Role = user.Role
        };
    }
}
