# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy project files
COPY ["backend/src/AttendanceSystem.Gateway/AttendanceSystem.Gateway.csproj", "src/AttendanceSystem.Gateway/"]

# Restore dependencies
RUN dotnet restore "src/AttendanceSystem.Gateway/AttendanceSystem.Gateway.csproj"

# Copy source code
COPY backend/src/AttendanceSystem.Gateway/ src/AttendanceSystem.Gateway/

# Build
WORKDIR /src/src/AttendanceSystem.Gateway
RUN dotnet build -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 appgroup \
    && adduser --system --uid 1001 --gid 1001 appuser

COPY --from=publish /app/publish .

RUN mkdir -p /app/logs && chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["dotnet", "AttendanceSystem.Gateway.dll"]
