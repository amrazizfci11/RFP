using AttendanceSystem.Application.Features.Clarification.Commands;
using AttendanceSystem.Application.Features.Clarification.Queries;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AttendanceSystem.Api.Controllers;

[Authorize]
public class ClarificationController : BaseController
{
    /// <summary>
    /// Get all clarification requests for current employee
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var result = await Mediator.Send(new GetClarificationsQuery(page, pageSize));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Get specific clarification by ID
    /// </summary>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var result = await Mediator.Send(new GetClarificationByIdQuery(id));
        if (!result.IsSuccess)
            return NotFound(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Get pending clarification count
    /// </summary>
    [HttpGet("pending/count")]
    public async Task<IActionResult> GetPendingCount()
    {
        var result = await Mediator.Send(new GetPendingClarificationCountQuery());
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(new { count = result.Value });
    }

    /// <summary>
    /// Respond to a clarification request
    /// </summary>
    [HttpPost("{id:guid}/respond")]
    public async Task<IActionResult> Respond(Guid id, [FromBody] RespondToClarificationCommand command)
    {
        if (id != command.Id)
            return BadRequest(new { error = "ID mismatch", code = "ID_MISMATCH" });

        var result = await Mediator.Send(command);
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Mark clarification as read
    /// </summary>
    [HttpPost("{id:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        var result = await Mediator.Send(new MarkClarificationAsReadCommand(id));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok();
    }
}
