namespace CarePathwayApi.Entities;

public class AnalysisCareStep
{
    public int Id { get; set; }
    public int AnalysisRecordId { get; set; }
    public AnalysisRecord AnalysisRecord { get; set; } = null!;
    public string Step { get; set; } = "";
}
