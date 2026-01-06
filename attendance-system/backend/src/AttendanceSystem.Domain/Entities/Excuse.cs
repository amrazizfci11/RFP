using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Enums;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents an excuse submitted by an employee
/// </summary>
public class Excuse : BaseEntity
{
    public Guid EmployeeId { get; private set; }
    public Employee Employee { get; private set; } = null!;

    public DateOnly Date { get; private set; }
    public ExcuseType Type { get; private set; }
    public string Reason { get; private set; } = string.Empty;
    public ExcuseStatus Status { get; private set; } = ExcuseStatus.Pending;

    // Review
    public Guid? ReviewedById { get; private set; }
    public string? ReviewedByName { get; private set; }
    public DateTime? ReviewedAt { get; private set; }
    public string? ReviewNotes { get; private set; }

    // Attachments
    private readonly List<ExcuseAttachment> _attachments = new();
    public IReadOnlyCollection<ExcuseAttachment> Attachments => _attachments.AsReadOnly();

    private Excuse() { }

    public static Excuse Create(
        Guid employeeId,
        DateOnly date,
        ExcuseType type,
        string reason)
    {
        var excuse = new Excuse
        {
            EmployeeId = employeeId,
            Date = date,
            Type = type,
            Reason = reason,
            Status = ExcuseStatus.Pending
        };

        excuse.AddDomainEvent(new ExcuseSubmittedEvent(excuse.Id, employeeId, date));
        return excuse;
    }

    public void AddAttachment(ExcuseAttachment attachment)
    {
        _attachments.Add(attachment);
    }

    public void RemoveAttachment(Guid attachmentId)
    {
        var attachment = _attachments.FirstOrDefault(a => a.Id == attachmentId);
        if (attachment != null)
            _attachments.Remove(attachment);
    }

    public void Approve(Guid reviewerId, string reviewerName, string? notes = null)
    {
        if (Status != ExcuseStatus.Pending)
            throw new InvalidOperationException("Can only approve pending excuses");

        Status = ExcuseStatus.Approved;
        ReviewedById = reviewerId;
        ReviewedByName = reviewerName;
        ReviewedAt = DateTime.UtcNow;
        ReviewNotes = notes;

        AddDomainEvent(new ExcuseApprovedEvent(Id, EmployeeId, Date));
    }

    public void Reject(Guid reviewerId, string reviewerName, string notes)
    {
        if (Status != ExcuseStatus.Pending)
            throw new InvalidOperationException("Can only reject pending excuses");

        Status = ExcuseStatus.Rejected;
        ReviewedById = reviewerId;
        ReviewedByName = reviewerName;
        ReviewedAt = DateTime.UtcNow;
        ReviewNotes = notes;

        AddDomainEvent(new ExcuseRejectedEvent(Id, EmployeeId, Date, notes));
    }
}

public class ExcuseAttachment : BaseEntity
{
    public Guid ExcuseId { get; private set; }
    public string FileName { get; private set; } = string.Empty;
    public string FileUrl { get; private set; } = string.Empty;
    public string FileType { get; private set; } = string.Empty;
    public long FileSize { get; private set; }

    private ExcuseAttachment() { }

    public static ExcuseAttachment Create(
        Guid excuseId,
        string fileName,
        string fileUrl,
        string fileType,
        long fileSize)
    {
        return new ExcuseAttachment
        {
            ExcuseId = excuseId,
            FileName = fileName,
            FileUrl = fileUrl,
            FileType = fileType,
            FileSize = fileSize
        };
    }
}

// Domain Events
public class ExcuseSubmittedEvent : DomainEvent
{
    public Guid ExcuseId { get; }
    public Guid EmployeeId { get; }
    public DateOnly Date { get; }

    public ExcuseSubmittedEvent(Guid excuseId, Guid employeeId, DateOnly date)
    {
        ExcuseId = excuseId;
        EmployeeId = employeeId;
        Date = date;
    }
}

public class ExcuseApprovedEvent : DomainEvent
{
    public Guid ExcuseId { get; }
    public Guid EmployeeId { get; }
    public DateOnly Date { get; }

    public ExcuseApprovedEvent(Guid excuseId, Guid employeeId, DateOnly date)
    {
        ExcuseId = excuseId;
        EmployeeId = employeeId;
        Date = date;
    }
}

public class ExcuseRejectedEvent : DomainEvent
{
    public Guid ExcuseId { get; }
    public Guid EmployeeId { get; }
    public DateOnly Date { get; }
    public string Reason { get; }

    public ExcuseRejectedEvent(Guid excuseId, Guid employeeId, DateOnly date, string reason)
    {
        ExcuseId = excuseId;
        EmployeeId = employeeId;
        Date = date;
        Reason = reason;
    }
}
