using AttendanceSystem.Domain.Entities;
using AttendanceSystem.Domain.Enums;
using AttendanceSystem.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AttendanceSystem.Infrastructure.Persistence.Repositories;

public class CompanyRepository : BaseRepository<Company>, ICompanyRepository
{
    public CompanyRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<Company?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(c => c.Email.ToLower() == email.ToLower(), cancellationToken);
    }

    public async Task<Company?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(c => c.SubscriptionPackage)
            .Include(c => c.Employees.Where(e => e.IsActive))
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);
    }

    public async Task<IReadOnlyList<Company>> GetActiveCompaniesAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(c => c.SubscriptionStatus == SubscriptionStatus.Active)
            .Include(c => c.SubscriptionPackage)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Company>> GetExpiringSubscriptionsAsync(
        int daysUntilExpiry,
        CancellationToken cancellationToken = default)
    {
        var expiryDate = DateTime.UtcNow.AddDays(daysUntilExpiry);
        return await _dbSet
            .Where(c => c.SubscriptionStatus == SubscriptionStatus.Active
                && c.SubscriptionEndDate.HasValue
                && c.SubscriptionEndDate.Value <= expiryDate)
            .Include(c => c.SubscriptionPackage)
            .ToListAsync(cancellationToken);
    }

    public async Task<int> GetEmployeeCountAsync(Guid companyId, CancellationToken cancellationToken = default)
    {
        return await _context.Employees
            .CountAsync(e => e.CompanyId == companyId && e.IsActive, cancellationToken);
    }
}

public class EmployeeRepository : BaseRepository<Employee>, IEmployeeRepository
{
    public EmployeeRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<Employee?> GetByIqamaAsync(string iqamaNumber, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(e => e.IqamaNumber == iqamaNumber, cancellationToken);
    }

    public async Task<Employee?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(e => e.Email.ToLower() == email.ToLower(), cancellationToken);
    }

    public async Task<Employee?> GetByEmployeeNumberAsync(
        Guid companyId,
        string employeeNumber,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(e => e.CompanyId == companyId
                && e.EmployeeNumber == employeeNumber, cancellationToken);
    }

    public async Task<IReadOnlyList<Employee>> GetByCompanyAsync(
        Guid companyId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(e => e.CompanyId == companyId && e.IsActive)
            .OrderBy(e => e.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Employee>> GetByDepartmentAsync(
        Guid companyId,
        string department,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(e => e.CompanyId == companyId
                && e.Department == department
                && e.IsActive)
            .OrderBy(e => e.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<Employee?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(e => e.Company)
            .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);
    }
}
