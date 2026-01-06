using AttendanceSystem.Application.Common.Interfaces;
using AttendanceSystem.Application.Common.Models;
using AttendanceSystem.Domain.Interfaces;
using AttendanceSystem.Domain.ValueObjects;
using FluentValidation;
using MediatR;

namespace AttendanceSystem.Application.Features.Attendance.Commands;

public record CheckOutCommand(
    double Latitude,
    double Longitude,
    double Accuracy,
    string? Notes) : IRequest<Result<AttendanceResponse>>;

public class CheckOutCommandValidator : AbstractValidator<CheckOutCommand>
{
    public CheckOutCommandValidator()
    {
        RuleFor(x => x.Latitude)
            .InclusiveBetween(-90, 90).WithMessage("Invalid latitude");

        RuleFor(x => x.Longitude)
            .InclusiveBetween(-180, 180).WithMessage("Invalid longitude");

        RuleFor(x => x.Accuracy)
            .GreaterThan(0).WithMessage("Accuracy must be positive");
    }
}

public class CheckOutCommandHandler : IRequestHandler<CheckOutCommand, Result<AttendanceResponse>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserService _currentUserService;
    private readonly IDateTimeService _dateTimeService;

    public CheckOutCommandHandler(
        IUnitOfWork unitOfWork,
        ICurrentUserService currentUserService,
        IDateTimeService dateTimeService)
    {
        _unitOfWork = unitOfWork;
        _currentUserService = currentUserService;
        _dateTimeService = dateTimeService;
    }

    public async Task<Result<AttendanceResponse>> Handle(CheckOutCommand request, CancellationToken cancellationToken)
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

        var today = _dateTimeService.Today;

        // Get today's record
        var record = await _unitOfWork.Attendance.GetByDateAsync(employeeId.Value, today, cancellationToken);
        if (record == null || record.CheckInTime == null)
            return Result.Failure<AttendanceResponse>("Must check in before checking out", "NOT_CHECKED_IN");

        if (record.CheckOutTime != null)
            return Result.Failure<AttendanceResponse>("Already checked out today", "ALREADY_CHECKED_OUT");

        // Validate location
        if (company.Location != null)
        {
            var checkOutLocation = new Location(request.Latitude, request.Longitude);
            if (!checkOutLocation.IsWithinRadius(company.Location, company.AttendanceRadiusMeters))
                return Result.Failure<AttendanceResponse>("You are outside the allowed work location", "OUTSIDE_VICINITY");
        }

        var checkOutLocation2 = new Location(request.Latitude, request.Longitude);
        record.CheckOut(_dateTimeService.UtcNow, checkOutLocation2, request.Accuracy, company.WorkingHours);

        if (request.Notes != null)
            record.AddNotes(request.Notes);

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
