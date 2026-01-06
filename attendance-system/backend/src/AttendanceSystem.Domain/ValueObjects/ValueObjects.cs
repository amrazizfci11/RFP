using AttendanceSystem.Domain.Common;

namespace AttendanceSystem.Domain.ValueObjects;

/// <summary>
/// Value object representing a location with coordinates
/// </summary>
public class Location : ValueObject
{
    public double Latitude { get; private set; }
    public double Longitude { get; private set; }
    public double? RadiusInMeters { get; private set; }

    private Location() { }

    public Location(double latitude, double longitude, double? radiusInMeters = null)
    {
        if (latitude < -90 || latitude > 90)
            throw new ArgumentException("Latitude must be between -90 and 90", nameof(latitude));

        if (longitude < -180 || longitude > 180)
            throw new ArgumentException("Longitude must be between -180 and 180", nameof(longitude));

        Latitude = latitude;
        Longitude = longitude;
        RadiusInMeters = radiusInMeters;
    }

    public double DistanceTo(Location other)
    {
        const double earthRadius = 6371000; // meters

        var lat1 = Latitude * Math.PI / 180;
        var lat2 = other.Latitude * Math.PI / 180;
        var deltaLat = (other.Latitude - Latitude) * Math.PI / 180;
        var deltaLon = (other.Longitude - Longitude) * Math.PI / 180;

        var a = Math.Sin(deltaLat / 2) * Math.Sin(deltaLat / 2) +
                Math.Cos(lat1) * Math.Cos(lat2) *
                Math.Sin(deltaLon / 2) * Math.Sin(deltaLon / 2);

        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

        return earthRadius * c;
    }

    public bool IsWithinRadius(Location other, double radiusMeters)
    {
        return DistanceTo(other) <= radiusMeters;
    }

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return Latitude;
        yield return Longitude;
        yield return RadiusInMeters;
    }
}

/// <summary>
/// Value object representing a Saudi National Address
/// </summary>
public class NationalAddress : ValueObject
{
    public string BuildingNumber { get; private set; } = string.Empty;
    public string Street { get; private set; } = string.Empty;
    public string District { get; private set; } = string.Empty;
    public string City { get; private set; } = string.Empty;
    public string PostalCode { get; private set; } = string.Empty;
    public string AdditionalNumber { get; private set; } = string.Empty;

    private NationalAddress() { }

    public NationalAddress(
        string buildingNumber,
        string street,
        string district,
        string city,
        string postalCode,
        string additionalNumber)
    {
        BuildingNumber = buildingNumber;
        Street = street;
        District = district;
        City = city;
        PostalCode = postalCode;
        AdditionalNumber = additionalNumber;
    }

    public string ToFormattedString()
    {
        return $"{BuildingNumber} {Street}, {District}, {City} {PostalCode}-{AdditionalNumber}";
    }

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return BuildingNumber;
        yield return Street;
        yield return District;
        yield return City;
        yield return PostalCode;
        yield return AdditionalNumber;
    }
}

/// <summary>
/// Value object representing working hours
/// </summary>
public class WorkingHours : ValueObject
{
    public TimeOnly StartTime { get; private set; }
    public TimeOnly EndTime { get; private set; }
    public int GracePeriodMinutes { get; private set; }

    private WorkingHours() { }

    public WorkingHours(TimeOnly startTime, TimeOnly endTime, int gracePeriodMinutes = 15)
    {
        if (endTime <= startTime)
            throw new ArgumentException("End time must be after start time");

        StartTime = startTime;
        EndTime = endTime;
        GracePeriodMinutes = gracePeriodMinutes;
    }

    public TimeSpan Duration => EndTime - StartTime;

    public bool IsLate(TimeOnly checkInTime)
    {
        var lateThreshold = StartTime.AddMinutes(GracePeriodMinutes);
        return checkInTime > lateThreshold;
    }

    public bool IsEarlyLeave(TimeOnly checkOutTime)
    {
        return checkOutTime < EndTime;
    }

    public TimeSpan GetLateBy(TimeOnly checkInTime)
    {
        if (!IsLate(checkInTime)) return TimeSpan.Zero;
        return checkInTime - StartTime;
    }

    public TimeSpan GetEarlyBy(TimeOnly checkOutTime)
    {
        if (!IsEarlyLeave(checkOutTime)) return TimeSpan.Zero;
        return EndTime - checkOutTime;
    }

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return StartTime;
        yield return EndTime;
        yield return GracePeriodMinutes;
    }
}

/// <summary>
/// Value object representing brand colors for white-label
/// </summary>
public class BrandColors : ValueObject
{
    public string PrimaryColor { get; private set; } = string.Empty;
    public string SecondaryColor { get; private set; } = string.Empty;

    private BrandColors() { }

    public BrandColors(string primaryColor, string secondaryColor)
    {
        if (!IsValidHexColor(primaryColor))
            throw new ArgumentException("Invalid primary color format", nameof(primaryColor));

        if (!IsValidHexColor(secondaryColor))
            throw new ArgumentException("Invalid secondary color format", nameof(secondaryColor));

        PrimaryColor = primaryColor.ToUpperInvariant();
        SecondaryColor = secondaryColor.ToUpperInvariant();
    }

    private static bool IsValidHexColor(string color)
    {
        if (string.IsNullOrEmpty(color)) return false;
        var hex = color.TrimStart('#');
        return hex.Length == 6 && hex.All(c => "0123456789ABCDEFabcdef".Contains(c));
    }

    protected override IEnumerable<object?> GetEqualityComponents()
    {
        yield return PrimaryColor;
        yield return SecondaryColor;
    }
}
