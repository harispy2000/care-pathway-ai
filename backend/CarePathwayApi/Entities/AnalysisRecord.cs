namespace CarePathwayApi.Entities;

public class AnalysisRecord
{
    public int Id { get; set; }

    public int? UserId { get; set; }
    public AppUser? User { get; set; }

    public int Age { get; set; }
    public string Gender { get; set; } = "";
    public string Symptoms { get; set; } = "";
    public string Duration { get; set; } = "";
    public string Severity { get; set; } = "";
    public string ExistingConditions { get; set; } = "";
    public string Medications { get; set; } = "";

    public string TriageLevel { get; set; } = "";
    public int RiskScore { get; set; }
    public string PossibleCondition { get; set; } = "";
    public string RecommendedAction { get; set; } = "";
    public string SafetyAdvice { get; set; } = "";

    public DateTime CreatedAt { get; set; } = DateTime.Now;

    public List<AnalysisCareStep> CareSteps { get; set; } = [];
    public List<AnalysisRedFlag> RedFlags { get; set; } = [];
    public List<AnalysisMatchedFactor> MatchedFactors { get; set; } = [];
}
