namespace CarePathwayApi.Entities;

public class PatientProfile
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public AppUser User { get; set; } = null!;

    public int Age { get; set; }
    public string Gender { get; set; } = "";
    public string PhoneNumber { get; set; } = "";
    public string BloodGroup { get; set; } = "";
    public string ExistingConditions { get; set; } = "";
    public string Medications { get; set; } = "";
    public string Allergies { get; set; } = "";
    public string EmergencyContactName { get; set; } = "";
    public string EmergencyContactNumber { get; set; } = "";
}
