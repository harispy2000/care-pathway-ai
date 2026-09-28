namespace CarePathwayApi.Entities;

public class AppUser
{
    public int Id { get; set; }
    public string FullName { get; set; } = "";
    public string Email { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string Role { get; set; } = "Patient";
    public string? FcmToken { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public PatientProfile? PatientProfile { get; set; }
    public List<AnalysisRecord> AnalysisRecords { get; set; } = [];
}
