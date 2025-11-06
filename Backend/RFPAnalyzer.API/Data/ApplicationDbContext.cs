using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using RFPAnalyzer.API.Models;

namespace RFPAnalyzer.API.Data;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<RFPDocument> Documents { get; set; }
    public DbSet<AnalysisResult> AnalysisResults { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        builder.Entity<ApplicationUser>()
            .HasMany(u => u.Documents)
            .WithOne(d => d.User)
            .HasForeignKey(d => d.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Entity<RFPDocument>()
            .HasOne(d => d.AnalysisResult)
            .WithOne(a => a.Document)
            .HasForeignKey<AnalysisResult>(a => a.DocumentId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
