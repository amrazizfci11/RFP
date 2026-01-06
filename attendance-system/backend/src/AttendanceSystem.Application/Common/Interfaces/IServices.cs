namespace AttendanceSystem.Application.Common.Interfaces;

public interface ICurrentUserService
{
    Guid? UserId { get; }
    Guid? CompanyId { get; }
    Guid? EmployeeId { get; }
    string? Username { get; }
    string? Role { get; }
    bool IsAuthenticated { get; }
}

public interface IDateTimeService
{
    DateTime UtcNow { get; }
    DateOnly Today { get; }
    TimeOnly CurrentTime { get; }
}

public interface IPasswordHasher
{
    string Hash(string password);
    bool Verify(string password, string hash);
}

public interface IJwtTokenService
{
    string GenerateAccessToken(Guid userId, string username, string role, Guid? companyId, Guid? employeeId);
    string GenerateRefreshToken();
    (Guid userId, string username, string role)? ValidateToken(string token);
}

public interface IOtpService
{
    string GenerateOtp();
    string GenerateRequestId();
    Task<bool> SendOtpAsync(string mobile, string otp, CancellationToken cancellationToken = default);
    bool VerifyOtp(string requestId, string otp);
}

public interface IEmailService
{
    Task SendEmailAsync(string to, string subject, string body, CancellationToken cancellationToken = default);
    Task SendTemplateEmailAsync(string to, string templateName, object model, CancellationToken cancellationToken = default);
}

public interface ISmsService
{
    Task SendSmsAsync(string mobile, string message, CancellationToken cancellationToken = default);
}

public interface IFileStorageService
{
    Task<string> UploadAsync(Stream stream, string fileName, string folder, CancellationToken cancellationToken = default);
    Task<Stream?> DownloadAsync(string fileUrl, CancellationToken cancellationToken = default);
    Task DeleteAsync(string fileUrl, CancellationToken cancellationToken = default);
}

public interface IPushNotificationService
{
    Task SendAsync(string deviceToken, string title, string body, object? data = null, CancellationToken cancellationToken = default);
    Task SendBulkAsync(IEnumerable<string> deviceTokens, string title, string body, object? data = null, CancellationToken cancellationToken = default);
}

public interface INafathService
{
    Task<NafathSession> InitiateAuthAsync(CancellationToken cancellationToken = default);
    Task<NafathVerifyResult?> VerifyAuthAsync(string transactionId, CancellationToken cancellationToken = default);
}

public record NafathSession(string TransactionId, string Random, DateTime ExpiresAt);
public record NafathVerifyResult(string Iqama, string Name, string? Email, string? Mobile);

public interface IReportService
{
    Task<byte[]> GeneratePdfReportAsync<T>(T data, string templateName, CancellationToken cancellationToken = default);
    Task<byte[]> GenerateExcelReportAsync<T>(IEnumerable<T> data, string sheetName, CancellationToken cancellationToken = default);
}

public interface ICacheService
{
    Task<T?> GetAsync<T>(string key, CancellationToken cancellationToken = default);
    Task SetAsync<T>(string key, T value, TimeSpan? expiration = null, CancellationToken cancellationToken = default);
    Task RemoveAsync(string key, CancellationToken cancellationToken = default);
    Task RemoveByPrefixAsync(string prefix, CancellationToken cancellationToken = default);
}
