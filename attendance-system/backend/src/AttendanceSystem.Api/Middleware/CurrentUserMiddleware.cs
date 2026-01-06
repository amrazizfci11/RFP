using System.Security.Claims;
using AttendanceSystem.Application.Common.Interfaces;

namespace AttendanceSystem.Api.Middleware;

public class CurrentUserMiddleware
{
    private readonly RequestDelegate _next;

    public CurrentUserMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, ICurrentUserService currentUserService)
    {
        if (context.User.Identity?.IsAuthenticated == true)
        {
            var userIdClaim = context.User.FindFirst(ClaimTypes.NameIdentifier);
            var companyIdClaim = context.User.FindFirst("companyId");
            var employeeIdClaim = context.User.FindFirst("employeeId");
            var roleClaim = context.User.FindFirst(ClaimTypes.Role);

            if (userIdClaim != null && Guid.TryParse(userIdClaim.Value, out var userId))
            {
                Guid? companyId = null;
                if (companyIdClaim != null && Guid.TryParse(companyIdClaim.Value, out var cId))
                    companyId = cId;

                Guid? employeeId = null;
                if (employeeIdClaim != null && Guid.TryParse(employeeIdClaim.Value, out var eId))
                    employeeId = eId;

                var role = roleClaim?.Value ?? "User";

                (currentUserService as CurrentUserService)?.SetUser(userId, companyId, employeeId, role);
            }
        }

        await _next(context);
    }
}

public class CurrentUserService : ICurrentUserService
{
    private Guid? _userId;
    private Guid? _companyId;
    private Guid? _employeeId;
    private string? _role;

    public Guid? UserId => _userId;
    public Guid? CompanyId => _companyId;
    public Guid? EmployeeId => _employeeId;
    public string? Role => _role;
    public bool IsAuthenticated => _userId.HasValue;

    public void SetUser(Guid userId, Guid? companyId, Guid? employeeId, string role)
    {
        _userId = userId;
        _companyId = companyId;
        _employeeId = employeeId;
        _role = role;
    }
}

public static class CurrentUserMiddlewareExtensions
{
    public static IApplicationBuilder UseCurrentUser(this IApplicationBuilder app)
    {
        return app.UseMiddleware<CurrentUserMiddleware>();
    }
}
