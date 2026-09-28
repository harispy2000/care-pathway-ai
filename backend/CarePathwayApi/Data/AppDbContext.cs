using CarePathwayApi.Entities;
using Microsoft.EntityFrameworkCore;

namespace CarePathwayApi.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<AppUser> AppUsers => Set<AppUser>();
    public DbSet<PatientProfile> PatientProfiles => Set<PatientProfile>();
    public DbSet<AnalysisRecord> AnalysisRecords => Set<AnalysisRecord>();
    public DbSet<AnalysisCareStep> AnalysisCareSteps => Set<AnalysisCareStep>();
    public DbSet<AnalysisRedFlag> AnalysisRedFlags => Set<AnalysisRedFlag>();
    public DbSet<AnalysisMatchedFactor> AnalysisMatchedFactors => Set<AnalysisMatchedFactor>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<AppUser>()
            .HasIndex(x => x.Email)
            .IsUnique();

        modelBuilder.Entity<AppUser>()
            .HasOne(x => x.PatientProfile)
            .WithOne(x => x.User)
            .HasForeignKey<PatientProfile>(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<AppUser>()
            .HasMany(x => x.AnalysisRecords)
            .WithOne(x => x.User)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.SetNull);

        modelBuilder.Entity<AnalysisRecord>()
            .HasMany(x => x.CareSteps)
            .WithOne(x => x.AnalysisRecord)
            .HasForeignKey(x => x.AnalysisRecordId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<AnalysisRecord>()
            .HasMany(x => x.RedFlags)
            .WithOne(x => x.AnalysisRecord)
            .HasForeignKey(x => x.AnalysisRecordId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<AnalysisRecord>()
            .HasMany(x => x.MatchedFactors)
            .WithOne(x => x.AnalysisRecord)
            .HasForeignKey(x => x.AnalysisRecordId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
