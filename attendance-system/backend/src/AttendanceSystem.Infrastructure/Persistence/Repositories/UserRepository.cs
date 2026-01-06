using AttendanceSystem.Domain.Entities;
using AttendanceSystem.Domain.Enums;
using AttendanceSystem.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AttendanceSystem.Infrastructure.Persistence.Repositories;

public class UserRepository : BaseRepository<ApplicationUser>, IUserRepository
{
    public UserRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<ApplicationUser?> GetByUsernameAsync(
        string username,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(u => u.Company)
            .Include(u => u.Employee)
            .FirstOrDefaultAsync(u => u.Username.ToLower() == username.ToLower(), cancellationToken);
    }

    public async Task<ApplicationUser?> GetByEmailAsync(
        string email,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(u => u.Company)
            .Include(u => u.Employee)
            .FirstOrDefaultAsync(u => u.Email.ToLower() == email.ToLower(), cancellationToken);
    }

    public async Task<ApplicationUser?> GetByRefreshTokenAsync(
        string refreshToken,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(u => u.Company)
            .Include(u => u.Employee)
            .FirstOrDefaultAsync(u => u.RefreshToken == refreshToken, cancellationToken);
    }

    public async Task<IReadOnlyList<ApplicationUser>> GetByCompanyAsync(
        Guid companyId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(u => u.Employee)
            .Where(u => u.CompanyId == companyId)
            .OrderBy(u => u.Username)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<ApplicationUser>> GetByRoleAsync(
        UserRole role,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(u => u.Company)
            .Where(u => u.Role == role)
            .OrderBy(u => u.Username)
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> ExistsByUsernameAsync(
        string username,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .AnyAsync(u => u.Username.ToLower() == username.ToLower(), cancellationToken);
    }

    public async Task<bool> ExistsByEmailAsync(
        string email,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .AnyAsync(u => u.Email.ToLower() == email.ToLower(), cancellationToken);
    }
}

public class ClarificationRepository : BaseRepository<Clarification>, IClarificationRepository
{
    public ClarificationRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<Clarification>> GetByEmployeeAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(c => c.EmployeeId == employeeId)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Clarification>> GetByCompanyAsync(
        Guid companyId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(c => c.Employee)
            .Where(c => c.Employee.CompanyId == companyId)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Clarification>> GetPendingByEmployeeAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(c => c.EmployeeId == employeeId
                && c.Status == ClarificationStatus.Pending)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<int> GetPendingCountAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .CountAsync(c => c.EmployeeId == employeeId
                && c.Status == ClarificationStatus.Pending, cancellationToken);
    }
}

public class NotificationRepository : BaseRepository<Notification>, INotificationRepository
{
    public NotificationRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<Notification>> GetByEmployeeAsync(
        Guid employeeId,
        int take = 50,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(n => n.EmployeeId == employeeId)
            .OrderByDescending(n => n.CreatedAt)
            .Take(take)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Notification>> GetUnreadByEmployeeAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(n => n.EmployeeId == employeeId && !n.IsRead)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<int> GetUnreadCountAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .CountAsync(n => n.EmployeeId == employeeId && !n.IsRead, cancellationToken);
    }

    public async Task MarkAllAsReadAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        await _dbSet
            .Where(n => n.EmployeeId == employeeId && !n.IsRead)
            .ExecuteUpdateAsync(n => n.SetProperty(x => x.IsRead, true), cancellationToken);
    }
}

public class SubscriptionPackageRepository : BaseRepository<SubscriptionPackage>, ISubscriptionPackageRepository
{
    public SubscriptionPackageRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<SubscriptionPackage>> GetActivePackagesAsync(
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(p => p.IsActive)
            .OrderBy(p => p.MonthlyPrice)
            .ToListAsync(cancellationToken);
    }

    public async Task<SubscriptionPackage?> GetByNameAsync(
        string name,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(p => p.Name.ToLower() == name.ToLower(), cancellationToken);
    }
}
