# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy solution and project files
COPY ["backend/AttendanceSystem.sln", "./"]
COPY ["backend/src/AttendanceSystem.Api/AttendanceSystem.Api.csproj", "src/AttendanceSystem.Api/"]
COPY ["backend/src/AttendanceSystem.Application/AttendanceSystem.Application.csproj", "src/AttendanceSystem.Application/"]
COPY ["backend/src/AttendanceSystem.Domain/AttendanceSystem.Domain.csproj", "src/AttendanceSystem.Domain/"]
COPY ["backend/src/AttendanceSystem.Infrastructure/AttendanceSystem.Infrastructure.csproj", "src/AttendanceSystem.Infrastructure/"]

# Restore dependencies
RUN dotnet restore

# Copy all source code
COPY backend/ .

# Build the application
WORKDIR /src/src/AttendanceSystem.Api
RUN dotnet build -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Create non-root user for security
RUN addgroup --system --gid 1001 appgroup \
    && adduser --system --uid 1001 --gid 1001 appuser

# Copy published files
COPY --from=publish /app/publish .

# Create directories for uploads and logs
RUN mkdir -p /app/uploads /app/logs \
    && chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose ports
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start the application
ENTRYPOINT ["dotnet", "AttendanceSystem.Api.dll"]
