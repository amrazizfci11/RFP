namespace RFPAnalyzer.API.Models;

public class AnalysisResult
{
    public int Id { get; set; }
    public int DocumentId { get; set; }
    public RFPDocument Document { get; set; } = null!;
    public string? ProjectName { get; set; }
    public string? ProjectDuration { get; set; }
    public string? HumanResourcesHierarchy { get; set; }
    public string? ProjectStages { get; set; }
    public string? SpecialConditions { get; set; }
    public string? ImplementationBoundaries { get; set; }
    public string RawAnalysis { get; set; } = string.Empty;
    public DateTime AnalyzedAt { get; set; } = DateTime.UtcNow;
}
