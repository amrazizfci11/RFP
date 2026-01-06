using AttendanceSystem.Application.Features.Notifications.Commands;
using AttendanceSystem.Application.Features.Notifications.Queries;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AttendanceSystem.Api.Controllers;

[Authorize]
public class NotificationsController : BaseController
{
    /// <summary>
    /// Get notifications for current user
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll(
        [FromQuery] int take = 50)
    {
        var result = await Mediator.Send(new GetNotificationsQuery(take));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Get unread notification count
    /// </summary>
    [HttpGet("unread/count")]
    public async Task<IActionResult> GetUnreadCount()
    {
        var result = await Mediator.Send(new GetUnreadNotificationCountQuery());
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(new { count = result.Value });
    }

    /// <summary>
    /// Mark notification as read
    /// </summary>
    [HttpPost("{id:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid id)
    {
        var result = await Mediator.Send(new MarkNotificationAsReadCommand(id));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok();
    }

    /// <summary>
    /// Mark all notifications as read
    /// </summary>
    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        var result = await Mediator.Send(new MarkAllNotificationsAsReadCommand());
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok();
    }
}
