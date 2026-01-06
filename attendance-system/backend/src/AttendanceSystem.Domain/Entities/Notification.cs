using AttendanceSystem.Domain.Common;
using AttendanceSystem.Domain.Enums;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents a notification sent to a user
/// </summary>
public class Notification : BaseEntity
{
    public Guid UserId { get; private set; }
    public NotificationType Type { get; private set; }
    public string Title { get; private set; } = string.Empty;
    public string TitleAr { get; private set; } = string.Empty;
    public string Body { get; private set; } = string.Empty;
    public string BodyAr { get; private set; } = string.Empty;
    public string? Data { get; private set; } // JSON data
    public bool IsRead { get; private set; }
    public DateTime? ReadAt { get; private set; }
    public bool IsPushSent { get; private set; }
    public DateTime? PushSentAt { get; private set; }

    private Notification() { }

    public static Notification Create(
        Guid userId,
        NotificationType type,
        string title,
        string titleAr,
        string body,
        string bodyAr,
        string? data = null)
    {
        return new Notification
        {
            UserId = userId,
            Type = type,
            Title = title,
            TitleAr = titleAr,
            Body = body,
            BodyAr = bodyAr,
            Data = data
        };
    }

    public void MarkAsRead()
    {
        if (!IsRead)
        {
            IsRead = true;
            ReadAt = DateTime.UtcNow;
        }
    }

    public void MarkAsPushSent()
    {
        IsPushSent = true;
        PushSentAt = DateTime.UtcNow;
    }
}

/// <summary>
/// Represents a bulk message sent by admin
/// </summary>
public class BulkMessage : BaseEntity
{
    public Guid CompanyId { get; private set; }
    public Guid SentById { get; private set; }
    public string SentByName { get; private set; } = string.Empty;
    public string Title { get; private set; } = string.Empty;
    public string TitleAr { get; private set; } = string.Empty;
    public string Body { get; private set; } = string.Empty;
    public string BodyAr { get; private set; } = string.Empty;
    public bool SendToAll { get; private set; }
    public List<Guid> RecipientIds { get; private set; } = new();
    public int TotalRecipients { get; private set; }
    public int DeliveredCount { get; private set; }
    public DateTime SentAt { get; private set; }

    private BulkMessage() { }

    public static BulkMessage Create(
        Guid companyId,
        Guid sentById,
        string sentByName,
        string title,
        string titleAr,
        string body,
        string bodyAr,
        bool sendToAll,
        List<Guid>? recipientIds = null)
    {
        return new BulkMessage
        {
            CompanyId = companyId,
            SentById = sentById,
            SentByName = sentByName,
            Title = title,
            TitleAr = titleAr,
            Body = body,
            BodyAr = bodyAr,
            SendToAll = sendToAll,
            RecipientIds = recipientIds ?? new(),
            SentAt = DateTime.UtcNow
        };
    }

    public void SetTotalRecipients(int count)
    {
        TotalRecipients = count;
    }

    public void IncrementDelivered()
    {
        DeliveredCount++;
    }
}
