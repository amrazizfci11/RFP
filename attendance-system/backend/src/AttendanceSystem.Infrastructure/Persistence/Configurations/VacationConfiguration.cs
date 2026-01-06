using AttendanceSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AttendanceSystem.Infrastructure.Persistence.Configurations;

public class VacationConfiguration : IEntityTypeConfiguration<Vacation>
{
    public void Configure(EntityTypeBuilder<Vacation> builder)
    {
        builder.ToTable("Vacations");

        builder.HasKey(v => v.Id);

        builder.Property(v => v.StartDate)
            .IsRequired();

        builder.Property(v => v.EndDate)
            .IsRequired();

        builder.Property(v => v.Type)
            .HasConversion<string>()
            .HasMaxLength(50);

        builder.Property(v => v.Reason)
            .HasMaxLength(1000);

        builder.Property(v => v.Status)
            .HasConversion<string>()
            .HasMaxLength(50);

        builder.Property(v => v.RejectionReason)
            .HasMaxLength(500);

        // Relationships
        builder.HasOne(v => v.Employee)
            .WithMany(e => e.Vacations)
            .HasForeignKey(v => v.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(v => v.Status);
        builder.HasIndex(v => new { v.EmployeeId, v.StartDate, v.EndDate });
        builder.HasIndex(v => new { v.StartDate, v.EndDate });
    }
}

public class ClarificationConfiguration : IEntityTypeConfiguration<Clarification>
{
    public void Configure(EntityTypeBuilder<Clarification> builder)
    {
        builder.ToTable("Clarifications");

        builder.HasKey(c => c.Id);

        builder.Property(c => c.Subject)
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(c => c.Message)
            .HasMaxLength(2000)
            .IsRequired();

        builder.Property(c => c.Response)
            .HasMaxLength(2000);

        builder.Property(c => c.Status)
            .HasConversion<string>()
            .HasMaxLength(50);

        // Relationships
        builder.HasOne(c => c.Employee)
            .WithMany(e => e.Clarifications)
            .HasForeignKey(c => c.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(c => c.Status);
        builder.HasIndex(c => c.EmployeeId);
        builder.HasIndex(c => c.CreatedAt);
    }
}

public class SubscriptionPackageConfiguration : IEntityTypeConfiguration<SubscriptionPackage>
{
    public void Configure(EntityTypeBuilder<SubscriptionPackage> builder)
    {
        builder.ToTable("SubscriptionPackages");

        builder.HasKey(s => s.Id);

        builder.Property(s => s.Name)
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(s => s.NameAr)
            .HasMaxLength(100);

        builder.Property(s => s.Description)
            .HasMaxLength(500);

        builder.Property(s => s.MonthlyPrice)
            .HasPrecision(18, 2);

        builder.Property(s => s.YearlyPrice)
            .HasPrecision(18, 2);

        builder.Property(s => s.MaxEmployees)
            .IsRequired();

        builder.Property(s => s.IsActive)
            .HasDefaultValue(true);

        // Store features as JSON
        builder.Property(s => s.Features)
            .HasConversion(
                v => string.Join("||", v),
                v => v.Split("||", StringSplitOptions.RemoveEmptyEntries).ToList());

        // Indexes
        builder.HasIndex(s => s.Name).IsUnique();
        builder.HasIndex(s => s.IsActive);
    }
}
