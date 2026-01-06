using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Enums;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents an application user for authentication
/// </summary>
public class ApplicationUser : BaseEntity
{
    public string Username { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public string Mobile { get; private set; } = string.Empty;
    public UserRole Role { get; private set; }
    public bool IsActive { get; private set; } = true;
    public bool EmailConfirmed { get; private set; }
    public bool MobileConfirmed { get; private set; }
    public bool IsBiometricEnabled { get; private set; }
    public string? BiometricToken { get; private set; }

    // MFA
    public bool TwoFactorEnabled { get; private set; } = true;
    public string? TwoFactorSecret { get; private set; }

    // Company association (for company admins and employees)
    public Guid? CompanyId { get; private set; }
    public Company? Company { get; private set; }

    // Employee association
    public Guid? EmployeeId { get; private set; }
    public Employee? Employee { get; private set; }

    // Lockout
    public DateTime? LockoutEnd { get; private set; }
    public int AccessFailedCount { get; private set; }

    // Tokens
    public string? RefreshToken { get; private set; }
    public DateTime? RefreshTokenExpiry { get; private set; }
    public string? FcmToken { get; private set; }

    // Last activity
    public DateTime? LastLoginAt { get; private set; }
    public string? LastLoginIp { get; private set; }

    private ApplicationUser() { }

    public static ApplicationUser CreateSuperAdmin(
        string username,
        string email,
        string passwordHash,
        string mobile)
    {
        return new ApplicationUser
        {
            Username = username,
            Email = email,
            PasswordHash = passwordHash,
            Mobile = mobile,
            Role = UserRole.SuperAdmin,
            EmailConfirmed = true,
            MobileConfirmed = true
        };
    }

    public static ApplicationUser CreateCompanyAdmin(
        Guid companyId,
        string username,
        string email,
        string passwordHash,
        string mobile)
    {
        return new ApplicationUser
        {
            CompanyId = companyId,
            Username = username,
            Email = email,
            PasswordHash = passwordHash,
            Mobile = mobile,
            Role = UserRole.CompanyAdmin
        };
    }

    public static ApplicationUser CreateEmployee(
        Guid companyId,
        Guid employeeId,
        string username,
        string email,
        string passwordHash,
        string mobile)
    {
        return new ApplicationUser
        {
            CompanyId = companyId,
            EmployeeId = employeeId,
            Username = username,
            Email = email,
            PasswordHash = passwordHash,
            Mobile = mobile,
            Role = UserRole.Employee
        };
    }

    public void UpdatePassword(string newPasswordHash)
    {
        PasswordHash = newPasswordHash;
        SetUpdatedBy("system");
    }

    public void ConfirmEmail()
    {
        EmailConfirmed = true;
    }

    public void ConfirmMobile()
    {
        MobileConfirmed = true;
    }

    public void EnableBiometric(string biometricToken)
    {
        IsBiometricEnabled = true;
        BiometricToken = biometricToken;
    }

    public void DisableBiometric()
    {
        IsBiometricEnabled = false;
        BiometricToken = null;
    }

    public void Enable2FA(string secret)
    {
        TwoFactorEnabled = true;
        TwoFactorSecret = secret;
    }

    public void Disable2FA()
    {
        TwoFactorEnabled = false;
        TwoFactorSecret = null;
    }

    public void RecordLogin(string ipAddress)
    {
        LastLoginAt = DateTime.UtcNow;
        LastLoginIp = ipAddress;
        AccessFailedCount = 0;
        LockoutEnd = null;
    }

    public void RecordFailedLogin()
    {
        AccessFailedCount++;
        if (AccessFailedCount >= 5)
        {
            LockoutEnd = DateTime.UtcNow.AddMinutes(15);
        }
    }

    public bool IsLockedOut => LockoutEnd.HasValue && LockoutEnd > DateTime.UtcNow;

    public void SetRefreshToken(string token, DateTime expiry)
    {
        RefreshToken = token;
        RefreshTokenExpiry = expiry;
    }

    public void RevokeRefreshToken()
    {
        RefreshToken = null;
        RefreshTokenExpiry = null;
    }

    public bool IsRefreshTokenValid(string token)
    {
        return RefreshToken == token &&
               RefreshTokenExpiry.HasValue &&
               RefreshTokenExpiry > DateTime.UtcNow;
    }

    public void SetFcmToken(string token)
    {
        FcmToken = token;
    }

    public void Activate() => IsActive = true;
    public void Deactivate() => IsActive = false;

    public void ChangeRole(UserRole newRole)
    {
        Role = newRole;
    }
}

/// <summary>
/// Company Admin user
/// </summary>
public class CompanyAdmin : BaseEntity
{
    public Guid UserId { get; private set; }
    public ApplicationUser User { get; private set; } = null!;
    public Guid CompanyId { get; private set; }
    public Company Company { get; private set; } = null!;
    public string Name { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string Mobile { get; private set; } = string.Empty;
    public bool IsPrimaryAdmin { get; private set; }
    public List<string> Permissions { get; private set; } = new();

    private CompanyAdmin() { }

    public static CompanyAdmin Create(
        Guid userId,
        Guid companyId,
        string name,
        string email,
        string mobile,
        bool isPrimaryAdmin = false)
    {
        return new CompanyAdmin
        {
            UserId = userId,
            CompanyId = companyId,
            Name = name,
            Email = email,
            Mobile = mobile,
            IsPrimaryAdmin = isPrimaryAdmin
        };
    }

    public void SetPermissions(List<string> permissions)
    {
        Permissions = permissions;
    }

    public bool HasPermission(string permission)
    {
        return IsPrimaryAdmin || Permissions.Contains(permission);
    }
}
