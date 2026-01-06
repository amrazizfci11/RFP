using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Enums;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents a clarification request sent to an employee
/// </summary>
public class Clarification : BaseEntity
{
    public Guid EmployeeId { get; private set; }
    public Employee Employee { get; private set; } = null!;

    public Guid RequestedById { get; private set; }
    public string RequestedByName { get; private set; } = string.Empty;

    public DateOnly StartDate { get; private set; }
    public DateOnly EndDate { get; private set; }
    public string Question { get; private set; } = string.Empty;
    public ClarificationStatus Status { get; private set; } = ClarificationStatus.Pending;

    // Response
    public string? Response { get; private set; }
    public DateTime? RespondedAt { get; private set; }

    // Due date
    public DateTime? DueDate { get; private set; }

    // Attachments
    private readonly List<ClarificationAttachment> _attachments = new();
    public IReadOnlyCollection<ClarificationAttachment> Attachments => _attachments.AsReadOnly();

    private Clarification() { }

    public static Clarification Create(
        Guid employeeId,
        Guid requestedById,
        string requestedByName,
        DateOnly startDate,
        DateOnly endDate,
        string question,
        DateTime? dueDate = null)
    {
        var clarification = new Clarification
        {
            EmployeeId = employeeId,
            RequestedById = requestedById,
            RequestedByName = requestedByName,
            StartDate = startDate,
            EndDate = endDate,
            Question = question,
            DueDate = dueDate,
            Status = ClarificationStatus.Pending
        };

        clarification.AddDomainEvent(new ClarificationRequestedEvent(
            clarification.Id, employeeId, requestedById, startDate, endDate));

        return clarification;
    }

    public void Respond(string response)
    {
        if (Status != ClarificationStatus.Pending)
            throw new InvalidOperationException("Clarification already responded");

        Response = response;
        RespondedAt = DateTime.UtcNow;
        Status = ClarificationStatus.Responded;

        AddDomainEvent(new ClarificationRespondedEvent(Id, EmployeeId, RequestedById));
    }

    public void AddAttachment(ClarificationAttachment attachment)
    {
        _attachments.Add(attachment);
    }

    public void Close()
    {
        Status = ClarificationStatus.Closed;
    }

    public bool IsOverdue => DueDate.HasValue && DateTime.UtcNow > DueDate && Status == ClarificationStatus.Pending;
}

public class ClarificationAttachment : BaseEntity
{
    public Guid ClarificationId { get; private set; }
    public string FileName { get; private set; } = string.Empty;
    public string FileUrl { get; private set; } = string.Empty;
    public string FileType { get; private set; } = string.Empty;
    public long FileSize { get; private set; }

    private ClarificationAttachment() { }

    public static ClarificationAttachment Create(
        Guid clarificationId,
        string fileName,
        string fileUrl,
        string fileType,
        long fileSize)
    {
        return new ClarificationAttachment
        {
            ClarificationId = clarificationId,
            FileName = fileName,
            FileUrl = fileUrl,
            FileType = fileType,
            FileSize = fileSize
        };
    }
}

// Domain Events
public class ClarificationRequestedEvent : DomainEvent
{
    public Guid ClarificationId { get; }
    public Guid EmployeeId { get; }
    public Guid RequestedById { get; }
    public DateOnly StartDate { get; }
    public DateOnly EndDate { get; }

    public ClarificationRequestedEvent(
        Guid clarificationId,
        Guid employeeId,
        Guid requestedById,
        DateOnly startDate,
        DateOnly endDate)
    {
        ClarificationId = clarificationId;
        EmployeeId = employeeId;
        RequestedById = requestedById;
        StartDate = startDate;
        EndDate = endDate;
    }
}

public class ClarificationRespondedEvent : DomainEvent
{
    public Guid ClarificationId { get; }
    public Guid EmployeeId { get; }
    public Guid RequestedById { get; }

    public ClarificationRespondedEvent(Guid clarificationId, Guid employeeId, Guid requestedById)
    {
        ClarificationId = clarificationId;
        EmployeeId = employeeId;
        RequestedById = requestedById;
    }
}
