using AttendanceSystem.Domain.Entities;
using AttendanceSystem.Domain.Enums;

namespace AttendanceSystem.Domain.Interfaces;

public interface ICompanyRepository : IRepository<Company>
{
    Task<Company?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Company>> GetActiveCompaniesAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Company>> GetExpiringSubscriptionsAsync(int daysUntilExpiry, CancellationToken cancellationToken = default);
    Task<int> GetEmployeeCountAsync(Guid companyId, CancellationToken cancellationToken = default);
}

public interface IEmployeeRepository : IRepository<Employee>
{
    Task<Employee?> GetByIqamaAsync(string iqama, Guid companyId, CancellationToken cancellationToken = default);
    Task<Employee?> GetWithUserAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Employee>> GetByCompanyAsync(Guid companyId, bool activeOnly = true, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Employee>> SearchAsync(Guid companyId, string searchTerm, CancellationToken cancellationToken = default);
}

public interface IAttendanceRepository : IRepository<AttendanceRecord>
{
    Task<AttendanceRecord?> GetByDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AttendanceRecord>> GetByDateRangeAsync(Guid employeeId, DateOnly startDate, DateOnly endDate, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AttendanceRecord>> GetByCompanyDateAsync(Guid companyId, DateOnly date, CancellationToken cancellationToken = default);
    Task<AttendanceSummary> GetSummaryAsync(Guid employeeId, DateOnly startDate, DateOnly endDate, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AttendanceRecord>> GetLateRecordsAsync(Guid companyId, DateOnly startDate, DateOnly endDate, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<AttendanceRecord>> GetAbsentRecordsAsync(Guid companyId, DateOnly date, CancellationToken cancellationToken = default);
}

public interface IExcuseRepository : IRepository<Excuse>
{
    Task<IReadOnlyList<Excuse>> GetByEmployeeAsync(Guid employeeId, ExcuseStatus? status = null, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Excuse>> GetPendingByCompanyAsync(Guid companyId, CancellationToken cancellationToken = default);
    Task<bool> HasExcuseForDateAsync(Guid employeeId, DateOnly date, CancellationToken cancellationToken = default);
}

public interface IVacationRepository : IRepository<Vacation>
{
    Task<IReadOnlyList<Vacation>> GetByEmployeeAsync(Guid employeeId, VacationStatus? status = null, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Vacation>> GetPendingByCompanyAsync(Guid companyId, CancellationToken cancellationToken = default);
    Task<bool> HasOverlappingVacationAsync(Guid employeeId, DateOnly startDate, DateOnly endDate, Guid? excludeVacationId = null, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Vacation>> GetActiveVacationsAsync(Guid companyId, DateOnly date, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Vacation>> GetUpcomingVacationsAsync(Guid employeeId, CancellationToken cancellationToken = default);
}

public interface IClarificationRepository : IRepository<Clarification>
{
    Task<IReadOnlyList<Clarification>> GetByEmployeeAsync(Guid employeeId, ClarificationStatus? status = null, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Clarification>> GetPendingByCompanyAsync(Guid companyId, CancellationToken cancellationToken = default);
    Task<int> GetPendingCountAsync(Guid employeeId, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<Clarification>> GetOverdueAsync(CancellationToken cancellationToken = default);
}

public interface IUserRepository : IRepository<ApplicationUser>
{
    Task<ApplicationUser?> GetByUsernameAsync(string username, CancellationToken cancellationToken = default);
    Task<ApplicationUser?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<ApplicationUser?> GetByRefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default);
    Task<ApplicationUser?> GetByBiometricTokenAsync(string biometricToken, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<ApplicationUser>> GetByCompanyAsync(Guid companyId, CancellationToken cancellationToken = default);
}

public interface INotificationRepository : IRepository<Notification>
{
    Task<IReadOnlyList<Notification>> GetByUserAsync(Guid userId, bool unreadOnly = false, int? limit = null, CancellationToken cancellationToken = default);
    Task<int> GetUnreadCountAsync(Guid userId, CancellationToken cancellationToken = default);
    Task MarkAllAsReadAsync(Guid userId, CancellationToken cancellationToken = default);
}

public interface ISubscriptionPackageRepository : IRepository<SubscriptionPackage>
{
    Task<IReadOnlyList<SubscriptionPackage>> GetActivePackagesAsync(CancellationToken cancellationToken = default);
}

/// <summary>
/// Attendance summary for reports
/// </summary>
public record AttendanceSummary(
    int TotalWorkingDays,
    int PresentDays,
    int AbsentDays,
    int LateDays,
    int EarlyLeaveDays,
    int VacationDays,
    int ExcuseDays,
    TimeSpan TotalWorkingHours,
    TimeSpan TotalOvertime,
    double AttendancePercentage);
