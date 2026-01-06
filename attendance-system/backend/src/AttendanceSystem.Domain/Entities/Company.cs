using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Enums;
using AttendanceSystem.Domain.ValueObjects;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents a company subscribed to the attendance system
/// </summary>
public class Company : BaseEntity
{
    public string Name { get; private set; } = string.Empty;
    public string NameAr { get; private set; } = string.Empty;
    public string? Logo { get; private set; }
    public string? Slogan { get; private set; }
    public string? SloganAr { get; private set; }
    public BrandColors BrandColors { get; private set; } = null!;
    public Location? Location { get; private set; }
    public NationalAddress? NationalAddress { get; private set; }
    public string? Address { get; private set; }
    public string Email { get; private set; } = string.Empty;
    public string Phone { get; private set; } = string.Empty;
    public string? BankAccount { get; private set; }
    public string? ZakatNumber { get; private set; }
    public double AttendanceRadiusMeters { get; private set; } = 100;
    public WorkingHours WorkingHours { get; private set; } = null!;
    public List<DayOfWeek> WorkingDays { get; private set; } = new();

    // Subscription
    public SubscriptionStatus SubscriptionStatus { get; private set; } = SubscriptionStatus.Trial;
    public DateTime SubscriptionStartDate { get; private set; }
    public DateTime SubscriptionEndDate { get; private set; }
    public int MaxEmployees { get; private set; }
    public Guid? SubscriptionPackageId { get; private set; }
    public SubscriptionPackage? SubscriptionPackage { get; private set; }

    // Navigation
    private readonly List<Employee> _employees = new();
    public IReadOnlyCollection<Employee> Employees => _employees.AsReadOnly();

    private readonly List<CompanyAdmin> _admins = new();
    public IReadOnlyCollection<CompanyAdmin> Admins => _admins.AsReadOnly();

    private Company() { }

    public static Company Create(
        string name,
        string nameAr,
        string email,
        string phone,
        BrandColors brandColors,
        WorkingHours workingHours,
        List<DayOfWeek> workingDays,
        int maxEmployees,
        DateTime subscriptionEndDate)
    {
        var company = new Company
        {
            Name = name,
            NameAr = nameAr,
            Email = email,
            Phone = phone,
            BrandColors = brandColors,
            WorkingHours = workingHours,
            WorkingDays = workingDays,
            MaxEmployees = maxEmployees,
            SubscriptionStartDate = DateTime.UtcNow,
            SubscriptionEndDate = subscriptionEndDate,
            SubscriptionStatus = SubscriptionStatus.Active
        };

        company.AddDomainEvent(new CompanyCreatedEvent(company.Id, company.Name));
        return company;
    }

    public void UpdateDetails(
        string name,
        string nameAr,
        string? slogan,
        string? sloganAr,
        BrandColors brandColors)
    {
        Name = name;
        NameAr = nameAr;
        Slogan = slogan;
        SloganAr = sloganAr;
        BrandColors = brandColors;
        SetUpdatedBy("system");
    }

    public void SetLocation(Location location, double radiusMeters)
    {
        Location = location;
        AttendanceRadiusMeters = radiusMeters;
    }

    public void SetNationalAddress(NationalAddress nationalAddress, string? address = null)
    {
        NationalAddress = nationalAddress;
        Address = address ?? nationalAddress.ToFormattedString();
    }

    public void SetLogo(string logoUrl)
    {
        Logo = logoUrl;
    }

    public void UpdateWorkingSchedule(WorkingHours workingHours, List<DayOfWeek> workingDays)
    {
        WorkingHours = workingHours;
        WorkingDays = workingDays;
    }

    public void SetBankDetails(string? bankAccount, string? zakatNumber)
    {
        BankAccount = bankAccount;
        ZakatNumber = zakatNumber;
    }

    public void RenewSubscription(DateTime newEndDate, int? newMaxEmployees = null)
    {
        SubscriptionEndDate = newEndDate;
        if (newMaxEmployees.HasValue)
            MaxEmployees = newMaxEmployees.Value;
        SubscriptionStatus = SubscriptionStatus.Active;
        AddDomainEvent(new SubscriptionRenewedEvent(Id, newEndDate));
    }

    public void SuspendSubscription()
    {
        SubscriptionStatus = SubscriptionStatus.Suspended;
        AddDomainEvent(new SubscriptionSuspendedEvent(Id));
    }

    public void CancelSubscription()
    {
        SubscriptionStatus = SubscriptionStatus.Cancelled;
        AddDomainEvent(new SubscriptionCancelledEvent(Id));
    }

    public bool IsSubscriptionActive()
    {
        return SubscriptionStatus == SubscriptionStatus.Active &&
               DateTime.UtcNow <= SubscriptionEndDate;
    }

    public bool CanAddEmployee()
    {
        return _employees.Count(e => !e.IsDeleted) < MaxEmployees;
    }

    public void AddEmployee(Employee employee)
    {
        if (!CanAddEmployee())
            throw new InvalidOperationException("Maximum employee limit reached");

        _employees.Add(employee);
    }

    public void AddAdmin(CompanyAdmin admin)
    {
        _admins.Add(admin);
    }

    public bool IsWorkingDay(DateTime date)
    {
        return WorkingDays.Contains(date.DayOfWeek);
    }
}

// Domain Events
public class CompanyCreatedEvent : DomainEvent
{
    public Guid CompanyId { get; }
    public string CompanyName { get; }

    public CompanyCreatedEvent(Guid companyId, string companyName)
    {
        CompanyId = companyId;
        CompanyName = companyName;
    }
}

public class SubscriptionRenewedEvent : DomainEvent
{
    public Guid CompanyId { get; }
    public DateTime NewEndDate { get; }

    public SubscriptionRenewedEvent(Guid companyId, DateTime newEndDate)
    {
        CompanyId = companyId;
        NewEndDate = newEndDate;
    }
}

public class SubscriptionSuspendedEvent : DomainEvent
{
    public Guid CompanyId { get; }
    public SubscriptionSuspendedEvent(Guid companyId) => CompanyId = companyId;
}

public class SubscriptionCancelledEvent : DomainEvent
{
    public Guid CompanyId { get; }
    public SubscriptionCancelledEvent(Guid companyId) => CompanyId = companyId;
}
