using CarePathwayApi.Data;
using CarePathwayApi.Entities;
using CarePathwayApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CarePathwayApi.Controllers;

[ApiController]
[Route("api/profile")]
public class ProfileController : ControllerBase
{
    private readonly AppDbContext _db;

    public ProfileController(AppDbContext db)
    {
        _db = db;
    }

    [HttpPost]
    public async Task<IActionResult> SaveProfile(PatientProfileRequest request)
    {
        var userExists = await _db.AppUsers.AnyAsync(x => x.Id == request.UserId);
        if (!userExists)
        {
            return BadRequest("User not found.");
        }

        var profile = await _db.PatientProfiles.FirstOrDefaultAsync(x => x.UserId == request.UserId);
        if (profile == null)
        {
            profile = new PatientProfile { UserId = request.UserId };
            _db.PatientProfiles.Add(profile);
        }

        profile.Age = request.Age;
        profile.Gender = request.Gender;
        profile.PhoneNumber = request.PhoneNumber;
        profile.BloodGroup = request.BloodGroup;
        profile.ExistingConditions = request.ExistingConditions;
        profile.Medications = request.Medications;
        profile.Allergies = request.Allergies;
        profile.EmergencyContactName = request.EmergencyContactName;
        profile.EmergencyContactNumber = request.EmergencyContactNumber;

        await _db.SaveChangesAsync();
        return Ok(profile);
    }

    [HttpGet("{userId:int}")]
    public async Task<IActionResult> GetProfile(int userId)
    {
        var profile = await _db.PatientProfiles.FirstOrDefaultAsync(x => x.UserId == userId);
        if (profile == null)
        {
            return NotFound();
        }

        return Ok(profile);
    }
}
