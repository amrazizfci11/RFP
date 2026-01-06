using AttendanceSystem.Application.Common.Interfaces;
using AttendanceSystem.Application.Common.Models;
using AttendanceSystem.Domain.Interfaces;
using FluentValidation;
using MediatR;

namespace AttendanceSystem.Application.Features.Auth.Commands;

public record LoginCommand(string Identifier, string Password) : IRequest<Result<LoginResponse>>;

public record LoginResponse(
    Guid UserId,
    string Username,
    string Name,
    string Email,
    string Role,
    Guid? CompanyId,
    string? CompanyName,
    Guid? EmployeeId,
    bool RequiresOtp,
    string? OtpRequestId,
    string? AccessToken,
    string? RefreshToken,
    DateTime? ExpiresAt);

public class LoginCommandValidator : AbstractValidator<LoginCommand>
{
    public LoginCommandValidator()
    {
        RuleFor(x => x.Identifier)
            .NotEmpty().WithMessage("Username or Iqama is required");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required")
            .MinimumLength(6).WithMessage("Password must be at least 6 characters");
    }
}

public class LoginCommandHandler : IRequestHandler<LoginCommand, Result<LoginResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IOtpService _otpService;

    public LoginCommandHandler(
        IUnitOfWork unitOfWork,
        IPasswordHasher passwordHasher,
        IJwtTokenService jwtTokenService,
        IOtpService otpService)
    {
        _unitOfWork = unitOfWork;
        _passwordHasher = passwordHasher;
        _jwtTokenService = jwtTokenService;
        _otpService = otpService;
    }

    public async Task<Result<LoginResponse>> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        // Find user by username or email
        var user = await _unitOfWork.Users.GetByUsernameAsync(request.Identifier, cancellationToken)
            ?? await _unitOfWork.Users.GetByEmailAsync(request.Identifier, cancellationToken);

        if (user == null)
            return Result.Failure<LoginResponse>("Invalid credentials", "INVALID_CREDENTIALS");

        if (!user.IsActive)
            return Result.Failure<LoginResponse>("Account is deactivated", "ACCOUNT_DEACTIVATED");

        if (user.IsLockedOut)
            return Result.Failure<LoginResponse>("Account is locked. Please try again later", "ACCOUNT_LOCKED");

        // Verify password
        if (!_passwordHasher.Verify(request.Password, user.PasswordHash))
        {
            user.RecordFailedLogin();
            await _unitOfWork.SaveChangesAsync(cancellationToken);
            return Result.Failure<LoginResponse>("Invalid credentials", "INVALID_CREDENTIALS");
        }

        // Get company and employee info
        string? companyName = null;
        if (user.CompanyId.HasValue)
        {
            var company = await _unitOfWork.Companies.GetByIdAsync(user.CompanyId.Value, cancellationToken);
            companyName = company?.Name;
        }

        string userName = user.Username;
        if (user.EmployeeId.HasValue)
        {
            var employee = await _unitOfWork.Employees.GetByIdAsync(user.EmployeeId.Value, cancellationToken);
            userName = employee?.Name ?? user.Username;
        }

        // Check if OTP is required
        if (user.TwoFactorEnabled)
        {
            var otp = _otpService.GenerateOtp();
            var requestId = _otpService.GenerateRequestId();

            await _otpService.SendOtpAsync(user.Mobile, otp, cancellationToken);

            return Result.Success(new LoginResponse(
                user.Id,
                user.Username,
                userName,
                user.Email,
                user.Role.ToString(),
                user.CompanyId,
                companyName,
                user.EmployeeId,
                RequiresOtp: true,
                OtpRequestId: requestId,
                AccessToken: null,
                RefreshToken: null,
                ExpiresAt: null));
        }

        // Generate tokens
        var accessToken = _jwtTokenService.GenerateAccessToken(
            user.Id, user.Username, user.Role.ToString(), user.CompanyId, user.EmployeeId);
        var refreshToken = _jwtTokenService.GenerateRefreshToken();
        var expiresAt = DateTime.UtcNow.AddDays(7);

        user.SetRefreshToken(refreshToken, expiresAt);
        user.RecordLogin(""); // IP would come from HttpContext

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success(new LoginResponse(
            user.Id,
            user.Username,
            userName,
            user.Email,
            user.Role.ToString(),
            user.CompanyId,
            companyName,
            user.EmployeeId,
            RequiresOtp: false,
            OtpRequestId: null,
            AccessToken: accessToken,
            RefreshToken: refreshToken,
            ExpiresAt: expiresAt));
    }
}
