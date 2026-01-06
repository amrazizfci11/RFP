using AttendanceSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AttendanceSystem.Infrastructure.Persistence.Configurations;

public class AttendanceRecordConfiguration : IEntityTypeConfiguration<AttendanceRecord>
{
    public void Configure(EntityTypeBuilder<AttendanceRecord> builder)
    {
        builder.ToTable("AttendanceRecords");

        builder.HasKey(a => a.Id);

        builder.Property(a => a.Date)
            .IsRequired();

        builder.Property(a => a.Status)
            .HasConversion<string>()
            .HasMaxLength(50);

        builder.Property(a => a.Notes)
            .HasMaxLength(1000);

        // Check-in location
        builder.OwnsOne(a => a.CheckInLocation, locationBuilder =>
        {
            locationBuilder.Property(l => l.Latitude)
                .HasColumnName("CheckInLatitude");
            locationBuilder.Property(l => l.Longitude)
                .HasColumnName("CheckInLongitude");
        });

        // Check-out location
        builder.OwnsOne(a => a.CheckOutLocation, locationBuilder =>
        {
            locationBuilder.Property(l => l.Latitude)
                .HasColumnName("CheckOutLatitude");
            locationBuilder.Property(l => l.Longitude)
                .HasColumnName("CheckOutLongitude");
        });

        // Relationships
        builder.HasOne(a => a.Employee)
            .WithMany(e => e.AttendanceRecords)
            .HasForeignKey(a => a.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(a => a.Date);
        builder.HasIndex(a => new { a.EmployeeId, a.Date }).IsUnique();
        builder.HasIndex(a => a.Status);
    }
}

public class ExcuseConfiguration : IEntityTypeConfiguration<Excuse>
{
    public void Configure(EntityTypeBuilder<Excuse> builder)
    {
        builder.ToTable("Excuses");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.Date)
            .IsRequired();

        builder.Property(e => e.Type)
            .HasConversion<string>()
            .HasMaxLength(50);

        builder.Property(e => e.Reason)
            .HasMaxLength(1000)
            .IsRequired();

        builder.Property(e => e.Status)
            .HasConversion<string>()
            .HasMaxLength(50);

        builder.Property(e => e.RejectionReason)
            .HasMaxLength(500);

        // Relationships
        builder.HasOne(e => e.Employee)
            .WithMany(emp => emp.Excuses)
            .HasForeignKey(e => e.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Attachments)
            .WithOne(a => a.Excuse)
            .HasForeignKey(a => a.ExcuseId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(e => e.Date);
        builder.HasIndex(e => e.Status);
        builder.HasIndex(e => new { e.EmployeeId, e.Date });
    }
}

public class ExcuseAttachmentConfiguration : IEntityTypeConfiguration<ExcuseAttachment>
{
    public void Configure(EntityTypeBuilder<ExcuseAttachment> builder)
    {
        builder.ToTable("ExcuseAttachments");

        builder.HasKey(a => a.Id);

        builder.Property(a => a.FileName)
            .HasMaxLength(256)
            .IsRequired();

        builder.Property(a => a.FileUrl)
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(a => a.ContentType)
            .HasMaxLength(100);

        builder.HasOne(a => a.Excuse)
            .WithMany(e => e.Attachments)
            .HasForeignKey(a => a.ExcuseId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
