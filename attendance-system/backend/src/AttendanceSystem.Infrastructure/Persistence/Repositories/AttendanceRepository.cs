using AttendanceSystem.Domain.Entities;
using AttendanceSystem.Domain.Enums;
using AttendanceSystem.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace AttendanceSystem.Infrastructure.Persistence.Repositories;

public class AttendanceRepository : BaseRepository<AttendanceRecord>, IAttendanceRepository
{
    public AttendanceRepository(ApplicationDbContext context) : base(context)
    {
    }

    public async Task<AttendanceRecord?> GetByDateAsync(
        Guid employeeId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .FirstOrDefaultAsync(a => a.EmployeeId == employeeId && a.Date == date, cancellationToken);
    }

    public async Task<IReadOnlyList<AttendanceRecord>> GetByDateRangeAsync(
        Guid employeeId,
        DateOnly startDate,
        DateOnly endDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(a => a.EmployeeId == employeeId
                && a.Date >= startDate
                && a.Date <= endDate)
            .OrderByDescending(a => a.Date)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<AttendanceRecord>> GetByCompanyAndDateAsync(
        Guid companyId,
        DateOnly date,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.Employee)
            .Where(a => a.Employee.CompanyId == companyId && a.Date == date)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<AttendanceRecord>> GetByCompanyAndDateRangeAsync(
        Guid companyId,
        DateOnly startDate,
        DateOnly endDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.Employee)
            .Where(a => a.Employee.CompanyId == companyId
                && a.Date >= startDate
                && a.Date <= endDate)
            .OrderByDescending(a => a.Date)
            .ThenBy(a => a.Employee.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<AttendanceRecord>> GetLateArrivalsAsync(
        Guid companyId,
        DateOnly startDate,
        DateOnly endDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.Employee)
            .Where(a => a.Employee.CompanyId == companyId
                && a.Date >= startDate
                && a.Date <= endDate
                && a.IsLate)
            .OrderByDescending(a => a.Date)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<AttendanceRecord>> GetEarlyLeavesAsync(
        Guid companyId,
        DateOnly startDate,
        DateOnly endDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.Employee)
            .Where(a => a.Employee.CompanyId == companyId
                && a.Date >= startDate
                && a.Date <= endDate
                && a.IsEarlyLeave)
            .OrderByDescending(a => a.Date)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<AttendanceRecord>> GetAbsentRecordsAsync(
        Guid companyId,
        DateOnly startDate,
        DateOnly endDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Include(a => a.Employee)
            .Where(a => a.Employee.CompanyId == companyId
                && a.Date >= startDate
                && a.Date <= endDate
                && a.Status == AttendanceStatus.Absent)
            .OrderByDescending(a => a.Date)
            .ToListAsync(cancellationToken);
    }

    public async Task<Dictionary<AttendanceStatus, int>> GetStatusSummaryAsync(
        Guid employeeId,
        DateOnly startDate,
        DateOnly endDate,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet
            .Where(a => a.EmployeeId == employeeId
                && a.Date >= startDate
                && a.Date <= endDate)
            .GroupBy(a => a.Status)
            .Select(g => new { Status = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Status, x => x.Count, cancellationToken);
    }
}
