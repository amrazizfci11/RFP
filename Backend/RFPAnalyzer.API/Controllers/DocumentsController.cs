using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RFPAnalyzer.API.Data;
using RFPAnalyzer.API.DTOs;
using RFPAnalyzer.API.Models;
using RFPAnalyzer.API.Services;
using System.Security.Claims;

namespace RFPAnalyzer.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DocumentsController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly IDocumentProcessingService _documentService;
    private readonly IClaudeAnalysisService _analysisService;
    private readonly ILogger<DocumentsController> _logger;
    private readonly IWebHostEnvironment _environment;

    public DocumentsController(
        ApplicationDbContext context,
        IDocumentProcessingService documentService,
        IClaudeAnalysisService analysisService,
        ILogger<DocumentsController> logger,
        IWebHostEnvironment environment)
    {
        _context = context;
        _documentService = documentService;
        _analysisService = analysisService;
        _logger = logger;
        _environment = environment;
    }

    private string GetUserId()
    {
        return User.FindFirst(ClaimTypes.NameIdentifier)?.Value
            ?? throw new UnauthorizedAccessException("User not authenticated");
    }

    [HttpGet]
    public async Task<ActionResult<List<DocumentDTO>>> GetUserDocuments()
    {
        var userId = GetUserId();

        var documents = await _context.Documents
            .Include(d => d.AnalysisResult)
            .Where(d => d.UserId == userId)
            .OrderByDescending(d => d.UploadedAt)
            .Select(d => new DocumentDTO
            {
                Id = d.Id,
                FileName = d.FileName,
                FileType = d.FileType,
                FileSize = d.FileSize,
                UploadedAt = d.UploadedAt,
                AnalysisResult = d.AnalysisResult != null ? new AnalysisResultDTO
                {
                    Id = d.AnalysisResult.Id,
                    DocumentId = d.AnalysisResult.DocumentId,
                    FileName = d.FileName,
                    ProjectName = d.AnalysisResult.ProjectName,
                    ProjectDuration = d.AnalysisResult.ProjectDuration,
                    HumanResourcesHierarchy = d.AnalysisResult.HumanResourcesHierarchy,
                    ProjectStages = d.AnalysisResult.ProjectStages,
                    SpecialConditions = d.AnalysisResult.SpecialConditions,
                    ImplementationBoundaries = d.AnalysisResult.ImplementationBoundaries,
                    RawAnalysis = d.AnalysisResult.RawAnalysis,
                    AnalyzedAt = d.AnalysisResult.AnalyzedAt
                } : null
            })
            .ToListAsync();

        return Ok(documents);
    }

    [HttpPost("upload")]
    public async Task<ActionResult<DocumentDTO>> UploadDocument([FromForm] IFormFile file)
    {
        var userId = GetUserId();

        // Check if user has reached the 10 file limit
        var userDocumentCount = await _context.Documents
            .CountAsync(d => d.UserId == userId);

        if (userDocumentCount >= 10)
        {
            return BadRequest(new { message = "You have reached the maximum limit of 10 documents" });
        }

        // Validate file type
        var allowedExtensions = new[] { ".pdf", ".doc", ".docx" };
        var fileExtension = Path.GetExtension(file.FileName).ToLower();

        if (!allowedExtensions.Contains(fileExtension))
        {
            return BadRequest(new { message = "Only PDF and Word documents are allowed" });
        }

        // Validate file size (max 50MB)
        if (file.Length > 50 * 1024 * 1024)
        {
            return BadRequest(new { message = "File size must not exceed 50MB" });
        }

        // Create uploads directory
        var uploadsPath = Path.Combine(_environment.ContentRootPath, "Uploads");
        Directory.CreateDirectory(uploadsPath);

        // Generate unique filename
        var uniqueFileName = $"{Guid.NewGuid()}{fileExtension}";
        var filePath = Path.Combine(uploadsPath, uniqueFileName);

        // Save file
        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        // Create database record
        var document = new RFPDocument
        {
            FileName = file.FileName,
            FilePath = filePath,
            FileType = fileExtension,
            FileSize = file.Length,
            UserId = userId,
            UploadedAt = DateTime.UtcNow
        };

        _context.Documents.Add(document);
        await _context.SaveChangesAsync();

        // Start analysis in background
        _ = Task.Run(async () => await AnalyzeDocumentBackground(document.Id));

        return Ok(new DocumentDTO
        {
            Id = document.Id,
            FileName = document.FileName,
            FileType = document.FileType,
            FileSize = document.FileSize,
            UploadedAt = document.UploadedAt
        });
    }

    private async Task AnalyzeDocumentBackground(int documentId)
    {
        try
        {
            var document = await _context.Documents.FindAsync(documentId);
            if (document == null) return;

            // Extract text from document
            var text = await _documentService.ExtractTextFromDocumentAsync(document.FilePath, document.FileType);

            // Analyze with Claude
            var analysis = await _analysisService.AnalyzeDocumentAsync(text);

            // Save results
            var analysisResult = new AnalysisResult
            {
                DocumentId = documentId,
                ProjectName = analysis.ProjectName,
                ProjectDuration = analysis.ProjectDuration,
                HumanResourcesHierarchy = analysis.HumanResourcesHierarchy,
                ProjectStages = analysis.ProjectStages,
                SpecialConditions = analysis.SpecialConditions,
                ImplementationBoundaries = analysis.ImplementationBoundaries,
                RawAnalysis = analysis.RawAnalysis,
                AnalyzedAt = DateTime.UtcNow
            };

            _context.AnalysisResults.Add(analysisResult);
            await _context.SaveChangesAsync();

            _logger.LogInformation($"Successfully analyzed document {documentId}");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Error analyzing document {documentId}");
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<DocumentDTO>> GetDocument(int id)
    {
        var userId = GetUserId();

        var document = await _context.Documents
            .Include(d => d.AnalysisResult)
            .FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId);

        if (document == null)
        {
            return NotFound();
        }

        return Ok(new DocumentDTO
        {
            Id = document.Id,
            FileName = document.FileName,
            FileType = document.FileType,
            FileSize = document.FileSize,
            UploadedAt = document.UploadedAt,
            AnalysisResult = document.AnalysisResult != null ? new AnalysisResultDTO
            {
                Id = document.AnalysisResult.Id,
                DocumentId = document.AnalysisResult.DocumentId,
                FileName = document.FileName,
                ProjectName = document.AnalysisResult.ProjectName,
                ProjectDuration = document.AnalysisResult.ProjectDuration,
                HumanResourcesHierarchy = document.AnalysisResult.HumanResourcesHierarchy,
                ProjectStages = document.AnalysisResult.ProjectStages,
                SpecialConditions = document.AnalysisResult.SpecialConditions,
                ImplementationBoundaries = document.AnalysisResult.ImplementationBoundaries,
                RawAnalysis = document.AnalysisResult.RawAnalysis,
                AnalyzedAt = document.AnalysisResult.AnalyzedAt
            } : null
        });
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteDocument(int id)
    {
        var userId = GetUserId();

        var document = await _context.Documents
            .FirstOrDefaultAsync(d => d.Id == id && d.UserId == userId);

        if (document == null)
        {
            return NotFound();
        }

        // Delete file
        if (System.IO.File.Exists(document.FilePath))
        {
            System.IO.File.Delete(document.FilePath);
        }

        _context.Documents.Remove(document);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
