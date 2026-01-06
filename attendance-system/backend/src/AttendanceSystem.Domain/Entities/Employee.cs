using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Enums;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents an employee in a company
/// </summary>
public class Employee : BaseEntity
{
    public string Iqama { get; private set; } = string.Empty;
    public string Name { get; private set; } = string.Empty;
    public string NameAr { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string Mobile { get; private set; } = string.Empty;
    public DateTime? DateOfBirth { get; private set; }
    public string? JobTitle { get; private set; }
    public string? JobTitleAr { get; private set; }
    public string? Department { get; private set; }
    public string? DepartmentAr { get; private set; }
    public string? ProfileImageUrl { get; private set; }
    public bool IsActive { get; private set; } = true;

    // Company relationship
    public Guid CompanyId { get; private set; }
    public Company Company { get; private set; } = null!;

    // User account relationship
    public Guid? UserId { get; private set; }
    public ApplicationUser? User { get; private set; }

    // Vacation balance
    public int AnnualVacationDays { get; private set; } = 21;
    public int SickLeaveDays { get; private set; } = 30;
    public int UsedAnnualDays { get; private set; }
    public int UsedSickDays { get; private set; }
    public int UnpaidDaysTaken { get; private set; }

    // Navigation
    private readonly List<AttendanceRecord> _attendanceRecords = new();
    public IReadOnlyCollection<AttendanceRecord> AttendanceRecords => _attendanceRecords.AsReadOnly();

    private readonly List<Excuse> _excuses = new();
    public IReadOnlyCollection<Excuse> Excuses => _excuses.AsReadOnly();

    private readonly List<Vacation> _vacations = new();
    public IReadOnlyCollection<Vacation> Vacations => _vacations.AsReadOnly();

    private Employee() { }

    public static Employee Create(
        Guid companyId,
        string iqama,
        string name,
        string nameAr,
        string email,
        string mobile,
        string? jobTitle = null,
        string? department = null,
        DateTime? dateOfBirth = null)
    {
        var employee = new Employee
        {
            CompanyId = companyId,
            Iqama = iqama,
            Name = name,
            NameAr = nameAr,
            Email = email,
            Mobile = mobile,
            JobTitle = jobTitle,
            Department = department,
            DateOfBirth = dateOfBirth
        };

        employee.AddDomainEvent(new EmployeeCreatedEvent(employee.Id, companyId, employee.Name));
        return employee;
    }

    public void UpdateProfile(
        string name,
        string nameAr,
        string email,
        string mobile,
        string? jobTitle,
        string? department,
        DateTime? dateOfBirth)
    {
        Name = name;
        NameAr = nameAr;
        Email = email;
        Mobile = mobile;
        JobTitle = jobTitle;
        Department = department;
        DateOfBirth = dateOfBirth;
    }

    public void SetProfileImage(string imageUrl)
    {
        ProfileImageUrl = imageUrl;
    }

    public void AssignUserAccount(Guid userId)
    {
        UserId = userId;
    }

    public void Activate()
    {
        IsActive = true;
        AddDomainEvent(new EmployeeActivatedEvent(Id));
    }

    public void Deactivate()
    {
        IsActive = false;
        AddDomainEvent(new EmployeeDeactivatedEvent(Id));
    }

    public void SetVacationAllowance(int annualDays, int sickDays)
    {
        AnnualVacationDays = annualDays;
        SickLeaveDays = sickDays;
    }

    public int GetRemainingAnnualDays() => AnnualVacationDays - UsedAnnualDays;
    public int GetRemainingSickDays() => SickLeaveDays - UsedSickDays;

    public void UseVacationDays(VacationType type, int days)
    {
        switch (type)
        {
            case VacationType.Annual:
                UsedAnnualDays += days;
                break;
            case VacationType.Sick:
                UsedSickDays += days;
                break;
            case VacationType.Unpaid:
                UnpaidDaysTaken += days;
                break;
        }
    }

    public void RestoreVacationDays(VacationType type, int days)
    {
        switch (type)
        {
            case VacationType.Annual:
                UsedAnnualDays = Math.Max(0, UsedAnnualDays - days);
                break;
            case VacationType.Sick:
                UsedSickDays = Math.Max(0, UsedSickDays - days);
                break;
            case VacationType.Unpaid:
                UnpaidDaysTaken = Math.Max(0, UnpaidDaysTaken - days);
                break;
        }
    }

    public void ResetYearlyVacationBalance()
    {
        UsedAnnualDays = 0;
        UsedSickDays = 0;
        UnpaidDaysTaken = 0;
    }
}

// Domain Events
public class EmployeeCreatedEvent : DomainEvent
{
    public Guid EmployeeId { get; }
    public Guid CompanyId { get; }
    public string EmployeeName { get; }

    public EmployeeCreatedEvent(Guid employeeId, Guid companyId, string employeeName)
    {
        EmployeeId = employeeId;
        CompanyId = companyId;
        EmployeeName = employeeName;
    }
}

public class EmployeeActivatedEvent : DomainEvent
{
    public Guid EmployeeId { get; }
    public EmployeeActivatedEvent(Guid employeeId) => EmployeeId = employeeId;
}

public class EmployeeDeactivatedEvent : DomainEvent
{
    public Guid EmployeeId { get; }
    public EmployeeDeactivatedEvent(Guid employeeId) => EmployeeId = employeeId;
}
