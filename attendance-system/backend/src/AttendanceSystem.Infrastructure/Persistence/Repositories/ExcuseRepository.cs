using AttendanceSystem.Domain.Entities;
using AttendanceSystem.Domain.Enums;
using AttendanceSystem.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AttendanceSystem.Infrastructure.Persistence.Repositories;

public class ExcuseRepository : BaseRepository<Excuse>, IExcuseRepository
{
    public ExcuseRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<Excuse>> GetByEmployeeAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(e => e.Attachments)
            .Where(e => e.EmployeeId == employeeId)
            .OrderByDescending(e => e.Date)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Excuse>> GetByCompanyAsync(
        Guid companyId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(e => e.Employee)
            .Include(e => e.Attachments)
            .Where(e => e.Employee.CompanyId == companyId)
            .OrderByDescending(e => e.Date)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Excuse>> GetPendingByCompanyAsync(
        Guid companyId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(e => e.Employee)
            .Include(e => e.Attachments)
            .Where(e => e.Employee.CompanyId == companyId
                && e.Status == ExcuseStatus.Pending)
            .OrderBy(e => e.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Excuse>> GetByDateRangeAsync(
        Guid employeeId,
        DateOnly startDate,
        DateOnly endDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(e => e.Attachments)
            .Where(e => e.EmployeeId == employeeId
                && e.Date >= startDate
                && e.Date <= endDate)
            .OrderByDescending(e => e.Date)
            .ToListAsync(cancellationToken);
    }

    public async Task<Excuse?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(e => e.Employee)
            .Include(e => e.Attachments)
            .FirstOrDefaultAsync(e => e.Id == id, cancellationToken);
    }

    public async Task<bool> HasExcuseForDateAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .AnyAsync(e => e.EmployeeId == employeeId
                && e.Date == date
                && e.Status != ExcuseStatus.Rejected, cancellationToken);
    }
}

public class VacationRepository : BaseRepository<Vacation>, IVacationRepository
{
    public VacationRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<IReadOnlyList<Vacation>> GetByEmployeeAsync(
        Guid employeeId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(v => v.EmployeeId == employeeId)
            .OrderByDescending(v => v.StartDate)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Vacation>> GetByCompanyAsync(
        Guid companyId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(v => v.Employee)
            .Where(v => v.Employee.CompanyId == companyId)
            .OrderByDescending(v => v.StartDate)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Vacation>> GetPendingByCompanyAsync(
        Guid companyId,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(v => v.Employee)
            .Where(v => v.Employee.CompanyId == companyId
                && v.Status == VacationStatus.Pending)
            .OrderBy(v => v.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Vacation>> GetActiveVacationsAsync(
        Guid companyId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(v => v.Employee)
            .Where(v => v.Employee.CompanyId == companyId
                && v.Status == VacationStatus.Approved
                && v.StartDate <= date
                && v.EndDate >= date)
            .ToListAsync(cancellationToken);
    }

    public async Task<bool> HasOverlappingVacationAsync(
        Guid employeeId,
        DateOnly startDate,
        DateOnly endDate,
        Guid? excludeVacationId,
        CancellationToken cancellationToken = default)
    {
        var query = _dbSet
            .Where(v => v.EmployeeId == employeeId
                && v.Status == VacationStatus.Approved
                && ((v.StartDate <= startDate && v.EndDate >= startDate)
                    || (v.StartDate <= endDate && v.EndDate >= endDate)
                    || (v.StartDate >= startDate && v.EndDate <= endDate)));

        if (excludeVacationId.HasValue)
            query = query.Where(v => v.Id != excludeVacationId.Value);

        return await query.AnyAsync(cancellationToken);
    }

    public async Task<int> GetUsedVacationDaysAsync(
        Guid employeeId,
        int year,
        CancellationToken cancellationToken = default)
    {
        var startOfYear = new DateOnly(year, 1, 1);
        var endOfYear = new DateOnly(year, 12, 31);

        return await _dbSet
            .Where(v => v.EmployeeId == employeeId
                && v.Status == VacationStatus.Approved
                && v.StartDate >= startOfYear
                && v.StartDate <= endOfYear)
            .SumAsync(v => v.TotalDays, cancellationToken);
    }

    public async Task<Vacation?> GetWithDetailsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(v => v.Employee)
            .FirstOrDefaultAsync(v => v.Id == id, cancellationToken);
    }
}
