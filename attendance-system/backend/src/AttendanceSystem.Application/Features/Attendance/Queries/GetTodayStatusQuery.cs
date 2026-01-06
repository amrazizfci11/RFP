using AttendanceSystem.Application.Common.Interfaces;
using AttendanceSystem.Application.Common.Models;
using AttendanceSystem.Domain.Interfaces;
using MediatR;

namespace AttendanceSystem.Application.Features.Attendance.Queries;

public record GetTodayStatusQuery : IRequest<Result<TodayStatusResponse>>;

public record TodayStatusResponse(
    AttendanceRecordDto? Record,
    bool CanCheckIn,
    bool CanCheckOut,
    CompanyLocationDto CompanyLocation,
    WorkScheduleDto WorkSchedule,
    string? Message);

public record AttendanceRecordDto(
    Guid Id,
    DateOnly Date,
    DateTime? CheckInTime,
    DateTime? CheckOutTime,
    string Status,
    bool IsLate,
    bool IsEarlyLeave,
    TimeSpan? LateBy,
    TimeSpan? EarlyBy,
    TimeSpan? WorkingDuration,
    TimeSpan? OvertimeDuration,
    string? Notes);

public record CompanyLocationDto(
    double Latitude,
    double Longitude,
    double RadiusMeters,
    string Address,
    string? NationalAddress);

public record WorkScheduleDto(
    int CheckInHour,
    int CheckInMinute,
    int CheckOutHour,
    int CheckOutMinute,
    int GracePeriodMinutes,
    List<int> WorkingDays);

public class GetTodayStatusQueryHandler : IRequestHandler<GetTodayStatusQuery, Result<TodayStatusResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserService _currentUserService;
    private readonly IDateTimeService _dateTimeService;

    public GetTodayStatusQueryHandler(
        IUnitOfWork unitOfWork,
        ICurrentUserService currentUserService,
        IDateTimeService dateTimeService)
    {
        _unitOfWork = unitOfWork;
        _currentUserService = currentUserService;
        _dateTimeService = dateTimeService;
    }

    public async Task<Result<TodayStatusResponse>> Handle(GetTodayStatusQuery request, CancellationToken cancellationToken)
    {
        var employeeId = _currentUserService.EmployeeId;
        if (!employeeId.HasValue)
            return Result.Failure<TodayStatusResponse>("Employee not found", "EMPLOYEE_NOT_FOUND");

        var employee = await _unitOfWork.Employees.GetByIdAsync(employeeId.Value, cancellationToken);
        if (employee == null)
            return Result.Failure<TodayStatusResponse>("Employee not found", "EMPLOYEE_NOT_FOUND");

        var company = await _unitOfWork.Companies.GetWithDetailsAsync(employee.CompanyId, cancellationToken);
        if (company == null)
            return Result.Failure<TodayStatusResponse>("Company not found", "COMPANY_NOT_FOUND");

        var today = _dateTimeService.Today;
        var record = await _unitOfWork.Attendance.GetByDateAsync(employeeId.Value, today, cancellationToken);

        // Check for active vacation
        var hasVacation = await _unitOfWork.Vacations
            .HasOverlappingVacationAsync(employeeId.Value, today, today, null, cancellationToken);

        var canCheckIn = !hasVacation && company.IsWorkingDay(DateTime.Today) && record?.CheckInTime == null;
        var canCheckOut = record?.CheckInTime != null && record.CheckOutTime == null;

        string? message = null;
        if (hasVacation)
            message = "You are on vacation today";
        else if (!company.IsWorkingDay(DateTime.Today))
            message = "Today is not a working day";

        AttendanceRecordDto? recordDto = null;
        if (record != null)
        {
            recordDto = new AttendanceRecordDto(
                record.Id,
                record.Date,
                record.CheckInTime,
                record.CheckOutTime,
                record.Status.ToString(),
                record.IsLate,
                record.IsEarlyLeave,
                record.LateBy,
                record.EarlyBy,
                record.WorkingDuration,
                record.OvertimeDuration,
                record.Notes);
        }

        var locationDto = new CompanyLocationDto(
            company.Location?.Latitude ?? 0,
            company.Location?.Longitude ?? 0,
            company.AttendanceRadiusMeters,
            company.Address ?? "",
            company.NationalAddress?.ToFormattedString());

        var scheduleDto = new WorkScheduleDto(
            company.WorkingHours.StartTime.Hour,
            company.WorkingHours.StartTime.Minute,
            company.WorkingHours.EndTime.Hour,
            company.WorkingHours.EndTime.Minute,
            company.WorkingHours.GracePeriodMinutes,
            company.WorkingDays.Select(d => (int)d).ToList());

        return Result.Success(new TodayStatusResponse(
            recordDto,
            canCheckIn,
            canCheckOut,
            locationDto,
            scheduleDto,
            message));
    }
}
