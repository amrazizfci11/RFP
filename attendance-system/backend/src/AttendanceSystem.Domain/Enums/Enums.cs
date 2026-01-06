namespace AttendanceSystem.Domain.Enums;

public enum SubscriptionStatus
{
    Trial,
    Active,
    Expired,
    Suspended,
    Cancelled
}

public enum AttendanceStatus
{
    Present,
    Absent,
    Late,
    EarlyLeave,
    Vacation,
    Excuse,
    Weekend,
    Holiday
}

public enum ExcuseStatus
{
    Pending,
    Approved,
    Rejected
}

public enum ExcuseType
{
    Sick,
    Personal,
    Emergency,
    Other
}

public enum VacationStatus
{
    Pending,
    Approved,
    Rejected,
    Cancelled
}

public enum VacationType
{
    Annual,
    Sick,
    Unpaid,
    Maternity,
    Paternity,
    Bereavement,
    Marriage,
    Hajj,
    Other
}

public enum ClarificationStatus
{
    Pending,
    Responded,
    Closed
}

public enum UserRole
{
    SuperAdmin,
    CompanyAdmin,
    Manager,
    Employee
}

public enum NotificationType
{
    AttendanceReminder,
    VacationApproved,
    VacationRejected,
    ExcuseApproved,
    ExcuseRejected,
    ClarificationRequest,
    GeneralAnnouncement
}

public enum ReportType
{
    Daily,
    Weekly,
    Monthly,
    Yearly,
    Custom
}

public enum ReportFormat
{
    Pdf,
    Excel
}
