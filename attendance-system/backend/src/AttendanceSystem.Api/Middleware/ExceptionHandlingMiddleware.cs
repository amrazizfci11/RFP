using System.Net;
using System.Text.Json;
using FluentValidation;

namespace AttendanceSystem.Api.Middleware;

public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        _logger.LogError(exception, "An unhandled exception occurred");

        var response = context.Response;
        response.ContentType = "application/json";

        var (statusCode, message, errorCode) = exception switch
        {
            ValidationException validationException => (
                HttpStatusCode.BadRequest,
                string.Join(", ", validationException.Errors.Select(e => e.ErrorMessage)),
                "VALIDATION_ERROR"),
            UnauthorizedAccessException => (
                HttpStatusCode.Unauthorized,
                "Unauthorized access",
                "UNAUTHORIZED"),
            KeyNotFoundException => (
                HttpStatusCode.NotFound,
                exception.Message,
                "NOT_FOUND"),
            ArgumentException => (
                HttpStatusCode.BadRequest,
                exception.Message,
                "BAD_REQUEST"),
            InvalidOperationException => (
                HttpStatusCode.BadRequest,
                exception.Message,
                "INVALID_OPERATION"),
            _ => (
                HttpStatusCode.InternalServerError,
                "An internal server error occurred",
                "INTERNAL_ERROR")
        };

        response.StatusCode = (int)statusCode;

        var result = JsonSerializer.Serialize(new
        {
            error = message,
            code = errorCode
        });

        await response.WriteAsync(result);
    }
}

public static class ExceptionHandlingMiddlewareExtensions
{
    public static IApplicationBuilder UseExceptionHandling(this IApplicationBuilder app)
    {
        return app.UseMiddleware<ExceptionHandlingMiddleware>();
    }
}
