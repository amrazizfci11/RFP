using AttendanceSystem.Application.Features.Reports.Queries;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AttendanceSystem.Api.Controllers;

[Authorize]
public class ReportsController : BaseController
{
    /// <summary>
    /// Generate attendance report for current employee
    /// </summary>
    [HttpGet("attendance")]
    public async Task<IActionResult> GetAttendanceReport(
        [FromQuery] DateOnly startDate,
        [FromQuery] DateOnly endDate,
        [FromQuery] string format = "pdf")
    {
        var result = await Mediator.Send(new GenerateAttendanceReportQuery(startDate, endDate, format));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        var contentType = format.ToLower() switch
        {
            "excel" or "xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            _ => "application/pdf"
        };

        var fileName = $"attendance_report_{startDate:yyyyMMdd}_{endDate:yyyyMMdd}.{(format.ToLower() == "excel" ? "xlsx" : "pdf")}";

        return File(result.Value.Data, contentType, fileName);
    }

    /// <summary>
    /// Get attendance statistics for dashboard
    /// </summary>
    [HttpGet("statistics")]
    public async Task<IActionResult> GetStatistics(
        [FromQuery] DateOnly? startDate,
        [FromQuery] DateOnly? endDate)
    {
        var result = await Mediator.Send(new GetAttendanceStatisticsQuery(startDate, endDate));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Get monthly attendance summary
    /// </summary>
    [HttpGet("monthly-summary")]
    public async Task<IActionResult> GetMonthlySummary(
        [FromQuery] int? year,
        [FromQuery] int? month)
    {
        var result = await Mediator.Send(new GetMonthlySummaryQuery(year, month));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }
}
