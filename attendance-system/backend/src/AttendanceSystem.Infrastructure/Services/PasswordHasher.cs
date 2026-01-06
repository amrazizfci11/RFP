using System.Security.Cryptography;
using AttendanceSystem.Application.Common.Interfaces;

namespace AttendanceSystem.Infrastructure.Services;

public class PasswordHasher : IPasswordHasher
{
    private const int SaltSize = 16;
    private const int HashSize = 32;
    private const int Iterations = 100000;
    private static readonly HashAlgorithmName Algorithm = HashAlgorithmName.SHA256;

    public string Hash(string password)
    {
        var salt = RandomNumberGenerator.GetBytes(SaltSize);
        var hash = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, Algorithm, HashSize);

        return $"{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
    }

    public bool Verify(string password, string passwordHash)
    {
        var parts = passwordHash.Split('.');
        if (parts.Length != 2)
            return false;

        var salt = Convert.FromBase64String(parts[0]);
        var hash = Convert.FromBase64String(parts[1]);

        var inputHash = Rfc2898DeriveBytes.Pbkdf2(password, salt, Iterations, Algorithm, HashSize);

        return CryptographicOperations.FixedTimeEquals(hash, inputHash);
    }
}

public class DateTimeService : IDateTimeService
{
    public DateTime UtcNow => DateTime.UtcNow;
    public DateOnly Today => DateOnly.FromDateTime(DateTime.UtcNow);
}

public class CurrentUserService : ICurrentUserService
{
    private Guid? _userId;
    private Guid? _companyId;
    private Guid? _employeeId;
    private string? _role;

    public Guid? UserId => _userId;
    public Guid? CompanyId => _companyId;
    public Guid? EmployeeId => _employeeId;
    public string? Role => _role;
    public bool IsAuthenticated => _userId.HasValue;

    public void SetUser(Guid userId, Guid? companyId, Guid? employeeId, string role)
    {
        _userId = userId;
        _companyId = companyId;
        _employeeId = employeeId;
        _role = role;
    }
}
