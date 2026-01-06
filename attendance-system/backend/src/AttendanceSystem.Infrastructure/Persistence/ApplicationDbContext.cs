using AttendanceSystem.Application.Common.Interfaces;
using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Reflection;

namespace AttendanceSystem.Infrastructure.Persistence;

public class ApplicationDbContext : DbContext, IApplicationDbContext
{
    private readonly ICurrentUserService _currentUserService;
    private readonly IDateTimeService _dateTimeService;

    public ApplicationDbContext(
        DbContextOptions<ApplicationDbContext> options,
        ICurrentUserService currentUserService,
        IDateTimeService dateTimeService)
        : base(options)
    {
        _currentUserService = currentUserService;
        _dateTimeService = dateTimeService;
    }

    public DbSet<Company> Companies => Set<Company>();
    public DbSet<SubscriptionPackage> SubscriptionPackages => Set<SubscriptionPackage>();
    public DbSet<Employee> Employees => Set<Employee>();
    public DbSet<AttendanceRecord> AttendanceRecords => Set<AttendanceRecord>();
    public DbSet<Excuse> Excuses => Set<Excuse>();
    public DbSet<ExcuseAttachment> ExcuseAttachments => Set<ExcuseAttachment>();
    public DbSet<Vacation> Vacations => Set<Vacation>();
    public DbSet<Clarification> Clarifications => Set<Clarification>();
    public DbSet<ApplicationUser> Users => Set<ApplicationUser>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        builder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
        base.OnModelCreating(builder);
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.SetCreatedBy(_currentUserService.UserId?.ToString());
                    entry.Entity.SetCreatedAt(_dateTimeService.UtcNow);
                    break;
                case EntityState.Modified:
                    entry.Entity.SetUpdatedBy(_currentUserService.UserId?.ToString());
                    entry.Entity.SetUpdatedAt(_dateTimeService.UtcNow);
                    break;
            }
        }

        var result = await base.SaveChangesAsync(cancellationToken);

        await DispatchDomainEventsAsync();

        return result;
    }

    private async Task DispatchDomainEventsAsync()
    {
        var entities = ChangeTracker
            .Entries<BaseEntity>()
            .Where(e => e.Entity.DomainEvents.Any())
            .Select(e => e.Entity)
            .ToList();

        var domainEvents = entities
            .SelectMany(e => e.DomainEvents)
            .ToList();

        entities.ForEach(e => e.ClearDomainEvents());

        // Domain events would be dispatched here via MediatR
        // For now, we just clear them
    }
}
