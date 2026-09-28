namespace CarePathwayApi.Models;

public class SaveFcmTokenRequest
{
    public int UserId { get; set; }
    public string FcmToken { get; set; } = "";
}
