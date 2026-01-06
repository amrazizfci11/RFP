using AttendanceSystem.Domain.Entities;
using AttendanceSystem.Domain.ValueObjects;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AttendanceSystem.Infrastructure.Persistence.Configurations;

public class CompanyConfiguration : IEntityTypeConfiguration<Company>
{
    public void Configure(EntityTypeBuilder<Company> builder)
    {
        builder.ToTable("Companies");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Name)
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(c => c.NameAr)
            .HasMaxLength(200);

        builder.Property(c => c.Email)
            .HasMaxLength(256)
            .IsRequired();

        builder.Property(c => c.Phone)
            .HasMaxLength(20);

        builder.Property(c => c.CommercialRegister)
            .HasMaxLength(50);

        builder.Property(c => c.TaxNumber)
            .HasMaxLength(50);

        builder.Property(c => c.Address)
            .HasMaxLength(500);

        builder.Property(c => c.LogoUrl)
            .HasMaxLength(500);

        builder.Property(c => c.SubscriptionStatus)
            .HasConversion<string>()
            .HasMaxLength(50);

        builder.Property(c => c.AttendanceRadiusMeters)
            .HasDefaultValue(100);

        // Value Objects
        builder.OwnsOne(c => c.Location, locationBuilder =>
        {
            locationBuilder.Property(l => l.Latitude)
                .HasColumnName("LocationLatitude");
            locationBuilder.Property(l => l.Longitude)
                .HasColumnName("LocationLongitude");
        });

        builder.OwnsOne(c => c.NationalAddress, naBuilder =>
        {
            naBuilder.Property(n => n.BuildingNumber)
                .HasColumnName("NationalAddress_BuildingNumber")
                .HasMaxLength(10);
            naBuilder.Property(n => n.Street)
                .HasColumnName("NationalAddress_Street")
                .HasMaxLength(200);
            naBuilder.Property(n => n.District)
                .HasColumnName("NationalAddress_District")
                .HasMaxLength(100);
            naBuilder.Property(n => n.City)
                .HasColumnName("NationalAddress_City")
                .HasMaxLength(100);
            naBuilder.Property(n => n.PostalCode)
                .HasColumnName("NationalAddress_PostalCode")
                .HasMaxLength(10);
            naBuilder.Property(n => n.AdditionalCode)
                .HasColumnName("NationalAddress_AdditionalCode")
                .HasMaxLength(10);
        });

        builder.OwnsOne(c => c.WorkingHours, whBuilder =>
        {
            whBuilder.Property(w => w.StartTime)
                .HasColumnName("WorkingHours_StartTime");
            whBuilder.Property(w => w.EndTime)
                .HasColumnName("WorkingHours_EndTime");
            whBuilder.Property(w => w.GracePeriodMinutes)
                .HasColumnName("WorkingHours_GracePeriodMinutes");
        });

        builder.OwnsOne(c => c.BrandColors, bcBuilder =>
        {
            bcBuilder.Property(b => b.PrimaryColor)
                .HasColumnName("BrandColors_PrimaryColor")
                .HasMaxLength(10);
            bcBuilder.Property(b => b.SecondaryColor)
                .HasColumnName("BrandColors_SecondaryColor")
                .HasMaxLength(10);
            bcBuilder.Property(b => b.AccentColor)
                .HasColumnName("BrandColors_AccentColor")
                .HasMaxLength(10);
        });

        // Store working days as JSON
        builder.Property(c => c.WorkingDays)
            .HasConversion(
                v => string.Join(",", v.Select(d => (int)d)),
                v => v.Split(",", StringSplitOptions.RemoveEmptyEntries)
                    .Select(s => (DayOfWeek)int.Parse(s))
                    .ToList());

        // Relationships
        builder.HasOne(c => c.SubscriptionPackage)
            .WithMany()
            .HasForeignKey(c => c.SubscriptionPackageId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(c => c.Employees)
            .WithOne(e => e.Company)
            .HasForeignKey(e => e.CompanyId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(c => c.Email).IsUnique();
        builder.HasIndex(c => c.CommercialRegister);
        builder.HasIndex(c => c.SubscriptionStatus);
    }
}
