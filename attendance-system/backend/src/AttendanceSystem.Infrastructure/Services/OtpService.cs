using System.Security.Cryptography;
using AttendanceSystem.Application.Common.Interfaces;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Logging;

namespace AttendanceSystem.Infrastructure.Services;

public class OtpService : IOtpService
{
    private readonly IDistributedCache _cache;
    private readonly ISmsService _smsService;
    private readonly ILogger<OtpService> _logger;
    private const int OtpLength = 6;
    private const int OtpExpirationMinutes = 5;

    public OtpService(
        IDistributedCache cache,
        ISmsService smsService,
        ILogger<OtpService> logger)
    {
        _cache = cache;
        _smsService = smsService;
        _logger = logger;
    }

    public string GenerateOtp()
    {
        var randomNumber = new byte[4];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomNumber);
        var value = Math.Abs(BitConverter.ToInt32(randomNumber, 0));
        return (value % (int)Math.Pow(10, OtpLength)).ToString($"D{OtpLength}");
    }

    public string GenerateRequestId()
    {
        return Guid.NewGuid().ToString("N");
    }

    public async Task SendOtpAsync(string phoneNumber, string otp, CancellationToken cancellationToken = default)
    {
        var key = $"otp:{phoneNumber}";
        await _cache.SetStringAsync(key, otp, new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(OtpExpirationMinutes)
        }, cancellationToken);

        var message = $"Your verification code is: {otp}. Valid for {OtpExpirationMinutes} minutes.";
        await _smsService.SendAsync(phoneNumber, message, cancellationToken);

        _logger.LogInformation("OTP sent to {PhoneNumber}", phoneNumber);
    }

    public async Task<bool> VerifyOtpAsync(
        string phoneNumber,
        string otp,
        CancellationToken cancellationToken = default)
    {
        var key = $"otp:{phoneNumber}";
        var storedOtp = await _cache.GetStringAsync(key, cancellationToken);

        if (string.IsNullOrEmpty(storedOtp))
            return false;

        if (storedOtp != otp)
            return false;

        // Remove OTP after successful verification
        await _cache.RemoveAsync(key, cancellationToken);
        return true;
    }
}

public class SmsService : ISmsService
{
    private readonly ILogger<SmsService> _logger;
    private readonly HttpClient _httpClient;

    public SmsService(ILogger<SmsService> logger, HttpClient httpClient)
    {
        _logger = logger;
        _httpClient = httpClient;
    }

    public async Task<bool> SendAsync(
        string phoneNumber,
        string message,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // TODO: Implement actual SMS provider integration (e.g., Twilio, Unifonic)
            _logger.LogInformation("SMS sent to {PhoneNumber}: {Message}", phoneNumber, message);
            await Task.CompletedTask;
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send SMS to {PhoneNumber}", phoneNumber);
            return false;
        }
    }

    public async Task<bool> SendBulkAsync(
        IEnumerable<string> phoneNumbers,
        string message,
        CancellationToken cancellationToken = default)
    {
        var tasks = phoneNumbers.Select(phone => SendAsync(phone, message, cancellationToken));
        var results = await Task.WhenAll(tasks);
        return results.All(r => r);
    }
}

public class EmailService : IEmailService
{
    private readonly ILogger<EmailService> _logger;

    public EmailService(ILogger<EmailService> logger)
    {
        _logger = logger;
    }

    public async Task<bool> SendAsync(
        string to,
        string subject,
        string body,
        bool isHtml = true,
        CancellationToken cancellationToken = default)
    {
        try
        {
            // TODO: Implement actual email provider integration (e.g., SendGrid, AWS SES)
            _logger.LogInformation("Email sent to {To}: {Subject}", to, subject);
            await Task.CompletedTask;
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send email to {To}", to);
            return false;
        }
    }

    public async Task<bool> SendTemplateAsync(
        string to,
        string templateId,
        object data,
        CancellationToken cancellationToken = default)
    {
        // TODO: Implement template-based email sending
        _logger.LogInformation("Template email sent to {To} using template {TemplateId}", to, templateId);
        await Task.CompletedTask;
        return true;
    }
}
