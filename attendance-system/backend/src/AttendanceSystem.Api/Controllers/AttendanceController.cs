using AttendanceSystem.Application.Features.Attendance.Commands;
using AttendanceSystem.Application.Features.Attendance.Queries;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AttendanceSystem.Api.Controllers;

[Authorize]
public class AttendanceController : BaseController
{
    /// <summary>
    /// Get today's attendance status
    /// </summary>
    [HttpGet("today")]
    public async Task<IActionResult> GetTodayStatus()
    {
        var result = await Mediator.Send(new GetTodayStatusQuery());
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Check in with GPS location
    /// </summary>
    [HttpPost("check-in")]
    public async Task<IActionResult> CheckIn([FromBody] CheckInCommand command)
    {
        var result = await Mediator.Send(command);
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Check out with GPS location
    /// </summary>
    [HttpPost("check-out")]
    public async Task<IActionResult> CheckOut([FromBody] CheckOutCommand command)
    {
        var result = await Mediator.Send(command);
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Get attendance history
    /// </summary>
    [HttpGet("history")]
    public async Task<IActionResult> GetHistory(
        [FromQuery] DateOnly? startDate,
        [FromQuery] DateOnly? endDate,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var result = await Mediator.Send(new GetAttendanceHistoryQuery(startDate, endDate, page, pageSize));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Get attendance summary (statistics)
    /// </summary>
    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary(
        [FromQuery] DateOnly? startDate,
        [FromQuery] DateOnly? endDate)
    {
        var result = await Mediator.Send(new GetAttendanceSummaryQuery(startDate, endDate));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Get specific attendance record
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await Mediator.Send(new GetAttendanceByIdQuery(id));
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }
}
