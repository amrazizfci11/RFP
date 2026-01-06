using AttendanceSystem.Application.Common.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace AttendanceSystem.Infrastructure.Services;

public class StorageService : IStorageService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<StorageService> _logger;
    private readonly string _storagePath;

    public StorageService(IConfiguration configuration, ILogger<StorageService> logger)
    {
        _configuration = configuration;
        _logger = logger;
        _storagePath = configuration["Storage:LocalPath"] ?? "uploads";
    }

    public async Task<string> UploadAsync(
        IFormFile file,
        string folder,
        CancellationToken cancellationToken = default)
    {
        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var folderPath = Path.Combine(_storagePath, folder);

        Directory.CreateDirectory(folderPath);

        var filePath = Path.Combine(folderPath, fileName);

        await using var stream = new FileStream(filePath, FileMode.Create);
        await file.CopyToAsync(stream, cancellationToken);

        _logger.LogInformation("File uploaded: {FilePath}", filePath);

        return $"/{folder}/{fileName}";
    }

    public async Task<string> UploadAsync(
        byte[] data,
        string fileName,
        string folder,
        CancellationToken cancellationToken = default)
    {
        var uniqueFileName = $"{Guid.NewGuid()}{Path.GetExtension(fileName)}";
        var folderPath = Path.Combine(_storagePath, folder);

        Directory.CreateDirectory(folderPath);

        var filePath = Path.Combine(folderPath, uniqueFileName);

        await File.WriteAllBytesAsync(filePath, data, cancellationToken);

        _logger.LogInformation("File uploaded: {FilePath}", filePath);

        return $"/{folder}/{uniqueFileName}";
    }

    public async Task<byte[]?> DownloadAsync(
        string path,
        CancellationToken cancellationToken = default)
    {
        var filePath = Path.Combine(_storagePath, path.TrimStart('/'));

        if (!File.Exists(filePath))
            return null;

        return await File.ReadAllBytesAsync(filePath, cancellationToken);
    }

    public Task<bool> DeleteAsync(string path, CancellationToken cancellationToken = default)
    {
        var filePath = Path.Combine(_storagePath, path.TrimStart('/'));

        if (!File.Exists(filePath))
            return Task.FromResult(false);

        File.Delete(filePath);
        _logger.LogInformation("File deleted: {FilePath}", filePath);

        return Task.FromResult(true);
    }

    public Task<string> GetSignedUrlAsync(
        string path,
        TimeSpan expiry,
        CancellationToken cancellationToken = default)
    {
        // For local storage, just return the path
        // In production, this would generate a signed URL for cloud storage
        return Task.FromResult(path);
    }
}

public class NafathService : INafathService
{
    private readonly IConfiguration _configuration;
    private readonly HttpClient _httpClient;
    private readonly ILogger<NafathService> _logger;

    public NafathService(
        IConfiguration configuration,
        HttpClient httpClient,
        ILogger<NafathService> logger)
    {
        _configuration = configuration;
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<NafathAuthResponse> InitiateAuthAsync(
        string nationalId,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // TODO: Implement actual Nafath API integration
            // This is a mock implementation
            var transactionId = Guid.NewGuid().ToString();
            var randomCode = new Random().Next(10, 99).ToString();

            _logger.LogInformation(
                "Nafath auth initiated for NationalId: {NationalId}, TransactionId: {TransactionId}",
                nationalId, transactionId);

            return new NafathAuthResponse
            {
                TransactionId = transactionId,
                RandomCode = randomCode,
                Status = "Pending"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to initiate Nafath auth for NationalId: {NationalId}", nationalId);
            throw;
        }
    }

    public async Task<NafathStatusResponse> CheckStatusAsync(
        string transactionId,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // TODO: Implement actual Nafath status check
            // This is a mock implementation
            _logger.LogInformation("Checking Nafath status for TransactionId: {TransactionId}", transactionId);

            return new NafathStatusResponse
            {
                TransactionId = transactionId,
                Status = "Completed",
                NationalId = "1234567890",
                FullName = "Test User",
                FullNameAr = "مستخدم تجريبي"
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to check Nafath status for TransactionId: {TransactionId}", transactionId);
            throw;
        }
    }
}

public class NafathAuthResponse
{
    public string TransactionId { get; set; } = default!;
    public string RandomCode { get; set; } = default!;
    public string Status { get; set; } = default!;
}

public class NafathStatusResponse
{
    public string TransactionId { get; set; } = default!;
    public string Status { get; set; } = default!;
    public string? NationalId { get; set; }
    public string? FullName { get; set; }
    public string? FullNameAr { get; set; }
}
