namespace CarePathwayApi.Models;

public class CarePathwayResponse
{
    public string TriageLevel { get; set; } = "";
    public int RiskScore { get; set; }
    public string PossibleCondition { get; set; } = "";
    public string RecommendedAction { get; set; } = "";
    public string SafetyAdvice { get; set; } = "";
    public List<string> MatchedFactors { get; set; } = [];
    public List<string> RedFlags { get; set; } = [];
    public List<string> CareSteps { get; set; } = [];
}
