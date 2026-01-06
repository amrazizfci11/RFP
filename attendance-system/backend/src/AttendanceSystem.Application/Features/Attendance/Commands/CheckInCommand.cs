using AttendanceSystem.Application.Common.Interfaces;
using AttendanceSystem.Application.Common.Models;
using AttendanceSystem.Domain.Entities;
using AttendanceSystem.Domain.Interfaces;
using AttendanceSystem.Domain.ValueObjects;
using FluentValidation;
using MediatR;

namespace AttendanceSystem.Application.Features.Attendance.Commands;

public record CheckInCommand(
    double Latitude,
    double Longitude,
    double Accuracy,
    string? Notes) : IRequest<Result<AttendanceResponse>>;

public record AttendanceResponse(
    Guid Id,
    DateOnly Date,
    DateTime? CheckInTime,
    DateTime? CheckOutTime,
    string Status,
    bool IsLate,
    TimeSpan? LateBy,
    TimeSpan? WorkingDuration);

public class CheckInCommandValidator : AbstractValidator<CheckInCommand>
{
    public CheckInCommandValidator()
    {
        RuleFor(x => x.Latitude)
            .InclusiveBetween(-90, 90).WithMessage("Invalid latitude");

        RuleFor(x => x.Longitude)
            .InclusiveBetween(-180, 180).WithMessage("Invalid longitude");

        RuleFor(x => x.Accuracy)
            .GreaterThan(0).WithMessage("Accuracy must be positive");
    }
}

public class CheckInCommandHandler : IRequestHandler<CheckInCommand, Result<AttendanceResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserService _currentUserService;
    private readonly IDateTimeService _dateTimeService;

    public CheckInCommandHandler(
        IUnitOfWork unitOfWork,
        ICurrentUserService currentUserService,
        IDateTimeService dateTimeService)
    {
        _unitOfWork = unitOfWork;
        _currentUserService = currentUserService;
        _dateTimeService = dateTimeService;
    }

    public async Task<Result<AttendanceResponse>> Handle(CheckInCommand request, CancellationToken cancellationToken)
    {
        var employeeId = _currentUserService.EmployeeId;
        if (!employeeId.HasValue)
            return Result.Failure<AttendanceResponse>("Employee not found", "EMPLOYEE_NOT_FOUND");

        var employee = await _unitOfWork.Employees.GetByIdAsync(employeeId.Value, cancellationToken);
        if (employee == null)
            return Result.Failure<AttendanceResponse>("Employee not found", "EMPLOYEE_NOT_FOUND");

        var company = await _unitOfWork.Companies.GetByIdAsync(employee.CompanyId, cancellationToken);
        if (company == null)
            return Result.Failure<AttendanceResponse>("Company not found", "COMPANY_NOT_FOUND");

        if (!company.IsSubscriptionActive())
            return Result.Failure<AttendanceResponse>("Company subscription is not active", "SUBSCRIPTION_INACTIVE");

        var today = _dateTimeService.Today;

        // Check if already checked in
        var existingRecord = await _unitOfWork.Attendance.GetByDateAsync(employeeId.Value, today, cancellationToken);
        if (existingRecord?.CheckInTime != null)
            return Result.Failure<AttendanceResponse>("Already checked in today", "ALREADY_CHECKED_IN");

        // Validate location
        if (company.Location != null)
        {
            var checkInLocation = new Location(request.Latitude, request.Longitude);
            if (!checkInLocation.IsWithinRadius(company.Location, company.AttendanceRadiusMeters))
                return Result.Failure<AttendanceResponse>("You are outside the allowed work location", "OUTSIDE_VICINITY");
        }

        // Create or update attendance record
        var record = existingRecord ?? AttendanceRecord.Create(employeeId.Value, today);

        var checkInLocation2 = new Location(request.Latitude, request.Longitude);
        record.CheckIn(_dateTimeService.UtcNow, checkInLocation2, request.Accuracy, company.WorkingHours);

        if (request.Notes != null)
            record.AddNotes(request.Notes);

        if (existingRecord == null)
            await _unitOfWork.Attendance.AddAsync(record, cancellationToken);

        await _unitOfWork.SaveChangesAsync(cancellationToken);

        return Result.Success(new AttendanceResponse(
            record.Id,
            record.Date,
            record.CheckInTime,
            record.CheckOutTime,
            record.Status.ToString(),
            record.IsLate,
            record.LateBy,
            record.WorkingDuration));
    }
}
