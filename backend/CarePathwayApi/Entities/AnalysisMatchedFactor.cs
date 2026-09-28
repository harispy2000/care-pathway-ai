namespace CarePathwayApi.Entities;

public class AnalysisMatchedFactor
{
    public int Id { get; set; }
    public int AnalysisRecordId { get; set; }
    public AnalysisRecord AnalysisRecord { get; set; } = null!;
    public string Factor { get; set; } = "";
}
