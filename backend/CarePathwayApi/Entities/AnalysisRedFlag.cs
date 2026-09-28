namespace CarePathwayApi.Entities;

public class AnalysisRedFlag
{
    public int Id { get; set; }
    public int AnalysisRecordId { get; set; }
    public AnalysisRecord AnalysisRecord { get; set; } = null!;
    public string RedFlag { get; set; } = "";
}
