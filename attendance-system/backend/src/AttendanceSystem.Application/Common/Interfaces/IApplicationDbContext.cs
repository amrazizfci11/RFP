using AttendanceSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace AttendanceSystem.Application.Common.Interfaces;

public interface IApplicationDbContext
{
    DbSet<Company> Companies { get; }
    DbSet<SubscriptionPackage> SubscriptionPackages { get; }
    DbSet<Employee> Employees { get; }
    DbSet<AttendanceRecord> AttendanceRecords { get; }
    DbSet<Excuse> Excuses { get; }
    DbSet<ExcuseAttachment> ExcuseAttachments { get; }
    DbSet<Vacation> Vacations { get; }
    DbSet<Clarification> Clarifications { get; }
    DbSet<ClarificationAttachment> ClarificationAttachments { get; }
    DbSet<ApplicationUser> Users { get; }
    DbSet<CompanyAdmin> CompanyAdmins { get; }
    DbSet<Notification> Notifications { get; }
    DbSet<BulkMessage> BulkMessages { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}
