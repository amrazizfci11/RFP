using AttendanceSystem.Domain.Interfaces;
using AttendanceSystem.Infrastructure.Persistence.Repositories;

namespace AttendanceSystem.Infrastructure.Persistence;

public class UnitOfWork : IUnitOfWork
{
    private readonly ApplicationDbContext _context;
    private ICompanyRepository? _companies;
    private IEmployeeRepository? _employees;
    private IAttendanceRepository? _attendance;
    private IExcuseRepository? _excuses;
    private IVacationRepository? _vacations;
    private IClarificationRepository? _clarifications;
    private IUserRepository? _users;
    private INotificationRepository? _notifications;
    private ISubscriptionPackageRepository? _subscriptionPackages;

    public UnitOfWork(ApplicationDbContext context)
    {
        _context = context;
    }

    public ICompanyRepository Companies =>
        _companies ??= new CompanyRepository(_context);

    public IEmployeeRepository Employees =>
        _employees ??= new EmployeeRepository(_context);

    public IAttendanceRepository Attendance =>
        _attendance ??= new AttendanceRepository(_context);

    public IExcuseRepository Excuses =>
        _excuses ??= new ExcuseRepository(_context);

    public IVacationRepository Vacations =>
        _vacations ??= new VacationRepository(_context);

    public IClarificationRepository Clarifications =>
        _clarifications ??= new ClarificationRepository(_context);

    public IUserRepository Users =>
        _users ??= new UserRepository(_context);

    public INotificationRepository Notifications =>
        _notifications ??= new NotificationRepository(_context);

    public ISubscriptionPackageRepository SubscriptionPackages =>
        _subscriptionPackages ??= new SubscriptionPackageRepository(_context);

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task BeginTransactionAsync(CancellationToken cancellationToken = default)
    {
        await _context.Database.BeginTransactionAsync(cancellationToken);
    }

    public async Task CommitTransactionAsync(CancellationToken cancellationToken = default)
    {
        await _context.Database.CommitTransactionAsync(cancellationToken);
    }

    public async Task RollbackTransactionAsync(CancellationToken cancellationToken = default)
    {
        await _context.Database.RollbackTransactionAsync(cancellationToken);
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}
