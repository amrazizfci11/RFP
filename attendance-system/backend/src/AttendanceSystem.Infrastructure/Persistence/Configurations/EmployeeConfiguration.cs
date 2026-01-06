using AttendanceSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AttendanceSystem.Infrastructure.Persistence.Configurations;

public class EmployeeConfiguration : IEntityTypeConfiguration<Employee>
{
    public void Configure(EntityTypeBuilder<Employee> builder)
    {
        builder.ToTable("Employees");

        builder.HasKey(e => e.Id);

        builder.Property(e => e.EmployeeNumber)
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(e => e.Name)
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(e => e.NameAr)
            .HasMaxLength(200);

        builder.Property(e => e.Email)
            .HasMaxLength(256)
            .IsRequired();

        builder.Property(e => e.Mobile)
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(e => e.IqamaNumber)
            .HasMaxLength(20);

        builder.Property(e => e.NationalId)
            .HasMaxLength(20);

        builder.Property(e => e.Position)
            .HasMaxLength(100);

        builder.Property(e => e.Department)
            .HasMaxLength(100);

        builder.Property(e => e.AnnualVacationDays)
            .HasDefaultValue(21);

        builder.Property(e => e.UsedVacationDays)
            .HasDefaultValue(0);

        builder.Property(e => e.IsActive)
            .HasDefaultValue(true);

        // Relationships
        builder.HasOne(e => e.Company)
            .WithMany(c => c.Employees)
            .HasForeignKey(e => e.CompanyId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.AttendanceRecords)
            .WithOne(a => a.Employee)
            .HasForeignKey(a => a.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Excuses)
            .WithOne(ex => ex.Employee)
            .HasForeignKey(ex => ex.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Vacations)
            .WithOne(v => v.Employee)
            .HasForeignKey(v => v.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(e => e.Clarifications)
            .WithOne(c => c.Employee)
            .HasForeignKey(c => c.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(e => e.EmployeeNumber);
        builder.HasIndex(e => e.Email);
        builder.HasIndex(e => e.IqamaNumber);
        builder.HasIndex(e => e.NationalId);
        builder.HasIndex(e => new { e.CompanyId, e.EmployeeNumber }).IsUnique();
    }
}
