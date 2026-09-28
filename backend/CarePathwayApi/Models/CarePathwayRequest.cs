namespace CarePathwayApi.Models;

public class CarePathwayRequest
{
    public int? UserId { get; set; }
    public int Age { get; set; }
    public string Gender { get; set; } = "";
    public string Symptoms { get; set; } = "";
    public string Duration { get; set; } = "";
    public string Severity { get; set; } = "";
    public string ExistingConditions { get; set; } = "";
    public string Medications { get; set; } = "";
}
