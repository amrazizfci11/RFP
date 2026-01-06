using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Enums;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents a vacation request submitted by an employee
/// </summary>
public class Vacation : BaseEntity
{
    public Guid EmployeeId { get; private set; }
    public Employee Employee { get; private set; } = null!;

    public VacationType Type { get; private set; }
    public DateOnly StartDate { get; private set; }
    public DateOnly EndDate { get; private set; }
    public int Days { get; private set; }
    public string Reason { get; private set; } = string.Empty;
    public VacationStatus Status { get; private set; } = VacationStatus.Pending;

    // Delegation
    public Guid? DelegateToId { get; private set; }
    public string? DelegateToName { get; private set; }

    // Review
    public Guid? ReviewedById { get; private set; }
    public string? ReviewedByName { get; private set; }
    public DateTime? ReviewedAt { get; private set; }
    public string? ReviewNotes { get; private set; }

    private Vacation() { }

    public static Vacation Create(
        Guid employeeId,
        VacationType type,
        DateOnly startDate,
        DateOnly endDate,
        string reason,
        Guid? delegateToId = null,
        string? delegateToName = null)
    {
        var days = endDate.DayNumber - startDate.DayNumber + 1;

        var vacation = new Vacation
        {
            EmployeeId = employeeId,
            Type = type,
            StartDate = startDate,
            EndDate = endDate,
            Days = days,
            Reason = reason,
            DelegateToId = delegateToId,
            DelegateToName = delegateToName,
            Status = VacationStatus.Pending
        };

        vacation.AddDomainEvent(new VacationRequestedEvent(vacation.Id, employeeId, type, startDate, endDate, days));
        return vacation;
    }

    public void Approve(Guid reviewerId, string reviewerName, string? notes = null)
    {
        if (Status != VacationStatus.Pending)
            throw new InvalidOperationException("Can only approve pending vacations");

        Status = VacationStatus.Approved;
        ReviewedById = reviewerId;
        ReviewedByName = reviewerName;
        ReviewedAt = DateTime.UtcNow;
        ReviewNotes = notes;

        AddDomainEvent(new VacationApprovedEvent(Id, EmployeeId, Type, Days));
    }

    public void Reject(Guid reviewerId, string reviewerName, string notes)
    {
        if (Status != VacationStatus.Pending)
            throw new InvalidOperationException("Can only reject pending vacations");

        Status = VacationStatus.Rejected;
        ReviewedById = reviewerId;
        ReviewedByName = reviewerName;
        ReviewedAt = DateTime.UtcNow;
        ReviewNotes = notes;

        AddDomainEvent(new VacationRejectedEvent(Id, EmployeeId, notes));
    }

    public void Cancel()
    {
        if (Status == VacationStatus.Cancelled)
            throw new InvalidOperationException("Vacation already cancelled");

        var wasApproved = Status == VacationStatus.Approved;
        Status = VacationStatus.Cancelled;

        AddDomainEvent(new VacationCancelledEvent(Id, EmployeeId, Type, Days, wasApproved));
    }

    public bool IsOngoing(DateOnly currentDate)
    {
        return Status == VacationStatus.Approved &&
               currentDate >= StartDate &&
               currentDate <= EndDate;
    }

    public bool IsUpcoming(DateOnly currentDate)
    {
        return Status == VacationStatus.Approved &&
               currentDate < StartDate;
    }
}

// Domain Events
public class VacationRequestedEvent : DomainEvent
{
    public Guid VacationId { get; }
    public Guid EmployeeId { get; }
    public VacationType Type { get; }
    public DateOnly StartDate { get; }
    public DateOnly EndDate { get; }
    public int Days { get; }

    public VacationRequestedEvent(
        Guid vacationId,
        Guid employeeId,
        VacationType type,
        DateOnly startDate,
        DateOnly endDate,
        int days)
    {
        VacationId = vacationId;
        EmployeeId = employeeId;
        Type = type;
        StartDate = startDate;
        EndDate = endDate;
        Days = days;
    }
}

public class VacationApprovedEvent : DomainEvent
{
    public Guid VacationId { get; }
    public Guid EmployeeId { get; }
    public VacationType Type { get; }
    public int Days { get; }

    public VacationApprovedEvent(Guid vacationId, Guid employeeId, VacationType type, int days)
    {
        VacationId = vacationId;
        EmployeeId = employeeId;
        Type = type;
        Days = days;
    }
}

public class VacationRejectedEvent : DomainEvent
{
    public Guid VacationId { get; }
    public Guid EmployeeId { get; }
    public string Reason { get; }

    public VacationRejectedEvent(Guid vacationId, Guid employeeId, string reason)
    {
        VacationId = vacationId;
        EmployeeId = employeeId;
        Reason = reason;
    }
}

public class VacationCancelledEvent : DomainEvent
{
    public Guid VacationId { get; }
    public Guid EmployeeId { get; }
    public VacationType Type { get; }
    public int Days { get; }
    public bool WasApproved { get; }

    public VacationCancelledEvent(Guid vacationId, Guid employeeId, VacationType type, int days, bool wasApproved)
    {
        VacationId = vacationId;
        EmployeeId = employeeId;
        Type = type;
        Days = days;
        WasApproved = wasApproved;
    }
}
