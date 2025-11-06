using Anthropic.SDK;
using Anthropic.SDK.Messaging;
using System.Text.Json;
using System.Text.RegularExpressions;

namespace RFPAnalyzer.API.Services;

public interface IClaudeAnalysisService
{
    Task<AnalysisResponse> AnalyzeDocumentAsync(string documentText);
}

public class AnalysisResponse
{
    public string? ProjectName { get; set; }
    public string? ProjectDuration { get; set; }
    public string? HumanResourcesHierarchy { get; set; }
    public string? ProjectStages { get; set; }
    public string? SpecialConditions { get; set; }
    public string? ImplementationBoundaries { get; set; }
    public string RawAnalysis { get; set; } = string.Empty;
}

public class ClaudeAnalysisService : IClaudeAnalysisService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<ClaudeAnalysisService> _logger;

    public ClaudeAnalysisService(IConfiguration configuration, ILogger<ClaudeAnalysisService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<AnalysisResponse> AnalyzeDocumentAsync(string documentText)
    {
        var apiKey = _configuration["Claude:ApiKey"]
            ?? throw new InvalidOperationException("Claude API Key not configured");

        var client = new AnthropicClient(apiKey);

        var analysisPrompt = @"Please analyze this RFP document and extract the following information in a structured format:

1. Project Name: The name or title of the project
2. Project Duration: The timeline or duration mentioned for the project
3. Human Resources Hierarchy: The organizational structure and roles needed for the project
4. Project Stages: The phases or stages of project implementation
5. Special Conditions: Any special requirements, conditions, or constraints
6. Implementation Boundaries: Governance frameworks mentioned (ITIL, governance policies, cybersecurity requirements, etc.)

Please structure your response as follows:
PROJECT NAME: [extracted information]
PROJECT DURATION: [extracted information]
HUMAN RESOURCES HIERARCHY: [extracted information]
PROJECT STAGES: [extracted information]
SPECIAL CONDITIONS: [extracted information]
IMPLEMENTATION BOUNDARIES: [extracted information]

If any information is not found in the document, state 'Not specified in document'.

Document text:
" + documentText;

        var messages = new List<Message>
        {
            new Message
            {
                Role = RoleType.User,
                Content = analysisPrompt
            }
        };

        var parameters = new MessageParameters
        {
            Messages = messages,
            Model = AnthropicModels.Claude3Sonnet,
            MaxTokens = 4096,
            Temperature = 0.3m
        };

        try
        {
            var response = await client.Messages.GetClaudeMessageAsync(parameters);
            var analysisText = response.Content.FirstOrDefault()?.Text ?? string.Empty;

            return ParseAnalysisResponse(analysisText);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling Claude API");
            throw;
        }
    }

    private AnalysisResponse ParseAnalysisResponse(string analysisText)
    {
        var response = new AnalysisResponse
        {
            RawAnalysis = analysisText
        };

        response.ProjectName = ExtractField(analysisText, "PROJECT NAME");
        response.ProjectDuration = ExtractField(analysisText, "PROJECT DURATION");
        response.HumanResourcesHierarchy = ExtractField(analysisText, "HUMAN RESOURCES HIERARCHY");
        response.ProjectStages = ExtractField(analysisText, "PROJECT STAGES");
        response.SpecialConditions = ExtractField(analysisText, "SPECIAL CONDITIONS");
        response.ImplementationBoundaries = ExtractField(analysisText, "IMPLEMENTATION BOUNDARIES");

        return response;
    }

    private string? ExtractField(string text, string fieldName)
    {
        var pattern = $@"{fieldName}:\s*(.+?)(?=\n[A-Z\s]+:|$)";
        var match = Regex.Match(text, pattern, RegexOptions.Singleline | RegexOptions.IgnoreCase);

        if (match.Success)
        {
            return match.Groups[1].Value.Trim();
        }

        return null;
    }
}
