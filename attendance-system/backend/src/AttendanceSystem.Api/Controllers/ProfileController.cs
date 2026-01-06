using AttendanceSystem.Application.Features.Profile.Commands;
using AttendanceSystem.Application.Features.Profile.Queries;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AttendanceSystem.Api.Controllers;

[Authorize]
public class ProfileController : BaseController
{
    /// <summary>
    /// Get current user profile
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetProfile()
    {
        var result = await Mediator.Send(new GetProfileQuery());
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Update profile photo
    /// </summary>
    [HttpPost("photo")]
    public async Task<IActionResult> UpdatePhoto([FromForm] UpdateProfilePhotoCommand command)
    {
        var result = await Mediator.Send(command);
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(result.Value);
    }

    /// <summary>
    /// Update notification preferences
    /// </summary>
    [HttpPut("notifications")]
    public async Task<IActionResult> UpdateNotificationPreferences([FromBody] UpdateNotificationPreferencesCommand command)
    {
        var result = await Mediator.Send(command);
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(new { message = "Preferences updated successfully" });
    }

    /// <summary>
    /// Register device for push notifications
    /// </summary>
    [HttpPost("devices")]
    public async Task<IActionResult> RegisterDevice([FromBody] RegisterDeviceCommand command)
    {
        var result = await Mediator.Send(command);
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return Ok(new { message = "Device registered successfully" });
    }

    /// <summary>
    /// Unregister device from push notifications
    /// </summary>
    [HttpDelete("devices/{deviceToken}")]
    public async Task<IActionResult> UnregisterDevice(string deviceToken)
    {
        var result = await Mediator.Send(new UnregisterDeviceCommand(deviceToken));
        if (!result.IsSuccess)
            return BadRequest(new { error = result.Error, code = result.ErrorCode });

        return NoContent();
    }
}
