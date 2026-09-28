namespace CarePathwayApi.Models;

public class AnalysisHistoryItemResponse
{
    public int Id { get; set; }
    public int? UserId { get; set; }
    public string Symptoms { get; set; } = "";
    public string TriageLevel { get; set; } = "";
    public int RiskScore { get; set; }
    public string RecommendedAction { get; set; } = "";
    public DateTime CreatedAt { get; set; }
}
