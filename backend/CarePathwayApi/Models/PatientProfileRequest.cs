namespace CarePathwayApi.Models;

public class PatientProfileRequest
{
    public int UserId { get; set; }
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
