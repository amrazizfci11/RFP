namespace RFPAnalyzer.API.DTOs;

public class AnalysisResultDTO
{
    public int Id { get; set; }
    public int DocumentId { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string? ProjectName { get; set; }
    public string? ProjectDuration { get; set; }
    public string? HumanResourcesHierarchy { get; set; }
    public string? ProjectStages { get; set; }
    public string? SpecialConditions { get; set; }
    public string? ImplementationBoundaries { get; set; }
    public string RawAnalysis { get; set; } = string.Empty;
    public DateTime AnalyzedAt { get; set; }
}

public class DocumentDTO
{
    public int Id { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty;
    public long FileSize { get; set; }
    public DateTime UploadedAt { get; set; }
    public AnalysisResultDTO? AnalysisResult { get; set; }
}
