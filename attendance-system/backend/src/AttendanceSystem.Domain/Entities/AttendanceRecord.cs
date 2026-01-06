using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Enums;
using AttendanceSystem.Domain.ValueObjects;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents a daily attendance record for an employee
/// </summary>
public class AttendanceRecord : BaseEntity
{
    public Guid EmployeeId { get; private set; }
    public Employee Employee { get; private set; } = null!;

    public DateOnly Date { get; private set; }
    public DateTime? CheckInTime { get; private set; }
    public DateTime? CheckOutTime { get; private set; }
    public Location? CheckInLocation { get; private set; }
    public Location? CheckOutLocation { get; private set; }
    public double? CheckInAccuracy { get; private set; }
    public double? CheckOutAccuracy { get; private set; }
    public AttendanceStatus Status { get; private set; } = AttendanceStatus.Absent;
    public bool IsLate { get; private set; }
    public bool IsEarlyLeave { get; private set; }
    public TimeSpan? LateBy { get; private set; }
    public TimeSpan? EarlyBy { get; private set; }
    public TimeSpan? WorkingDuration { get; private set; }
    public TimeSpan? OvertimeDuration { get; private set; }
    public string? Notes { get; private set; }

    private AttendanceRecord() { }

    public static AttendanceRecord Create(Guid employeeId, DateOnly date)
    {
        return new AttendanceRecord
        {
            EmployeeId = employeeId,
            Date = date,
            Status = AttendanceStatus.Absent
        };
    }

    public void CheckIn(
        DateTime checkInTime,
        Location location,
        double accuracy,
        WorkingHours workingHours)
    {
        if (CheckInTime.HasValue)
            throw new InvalidOperationException("Already checked in for today");

        CheckInTime = checkInTime;
        CheckInLocation = location;
        CheckInAccuracy = accuracy;

        var checkInTimeOnly = TimeOnly.FromDateTime(checkInTime);
        IsLate = workingHours.IsLate(checkInTimeOnly);

        if (IsLate)
        {
            LateBy = workingHours.GetLateBy(checkInTimeOnly);
            Status = AttendanceStatus.Late;
        }
        else
        {
            Status = AttendanceStatus.Present;
        }

        AddDomainEvent(new EmployeeCheckedInEvent(EmployeeId, Date, checkInTime, IsLate));
    }

    public void CheckOut(
        DateTime checkOutTime,
        Location location,
        double accuracy,
        WorkingHours workingHours)
    {
        if (!CheckInTime.HasValue)
            throw new InvalidOperationException("Must check in before checking out");

        if (CheckOutTime.HasValue)
            throw new InvalidOperationException("Already checked out for today");

        CheckOutTime = checkOutTime;
        CheckOutLocation = location;
        CheckOutAccuracy = accuracy;

        var checkOutTimeOnly = TimeOnly.FromDateTime(checkOutTime);
        IsEarlyLeave = workingHours.IsEarlyLeave(checkOutTimeOnly);

        if (IsEarlyLeave)
        {
            EarlyBy = workingHours.GetEarlyBy(checkOutTimeOnly);
            if (Status == AttendanceStatus.Present)
                Status = AttendanceStatus.EarlyLeave;
        }

        // Calculate working duration
        WorkingDuration = checkOutTime - CheckInTime.Value;

        // Calculate overtime
        var expectedDuration = workingHours.Duration;
        if (WorkingDuration > expectedDuration)
        {
            OvertimeDuration = WorkingDuration - expectedDuration;
        }

        AddDomainEvent(new EmployeeCheckedOutEvent(EmployeeId, Date, checkOutTime, WorkingDuration.Value));
    }

    public void MarkAsAbsent(string? reason = null)
    {
        Status = AttendanceStatus.Absent;
        Notes = reason;
    }

    public void MarkAsVacation()
    {
        Status = AttendanceStatus.Vacation;
    }

    public void MarkAsExcuse()
    {
        Status = AttendanceStatus.Excuse;
    }

    public void MarkAsWeekend()
    {
        Status = AttendanceStatus.Weekend;
    }

    public void MarkAsHoliday(string holidayName)
    {
        Status = AttendanceStatus.Holiday;
        Notes = holidayName;
    }

    public void AddNotes(string notes)
    {
        Notes = notes;
    }
}

// Domain Events
public class EmployeeCheckedInEvent : DomainEvent
{
    public Guid EmployeeId { get; }
    public DateOnly Date { get; }
    public DateTime CheckInTime { get; }
    public bool IsLate { get; }

    public EmployeeCheckedInEvent(Guid employeeId, DateOnly date, DateTime checkInTime, bool isLate)
    {
        EmployeeId = employeeId;
        Date = date;
        CheckInTime = checkInTime;
        IsLate = isLate;
    }
}

public class EmployeeCheckedOutEvent : DomainEvent
{
    public Guid EmployeeId { get; }
    public DateOnly Date { get; }
    public DateTime CheckOutTime { get; }
    public TimeSpan WorkingDuration { get; }

    public EmployeeCheckedOutEvent(Guid employeeId, DateOnly date, DateTime checkOutTime, TimeSpan workingDuration)
    {
        EmployeeId = employeeId;
        Date = date;
        CheckOutTime = checkOutTime;
        WorkingDuration = workingDuration;
    }
}
