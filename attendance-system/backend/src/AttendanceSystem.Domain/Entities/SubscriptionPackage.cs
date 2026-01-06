using AttendanceSystem.Domain.Common;

namespace AttendanceSystem.Domain.Entities;

/// <summary>
/// Represents a subscription package for companies
/// </summary>
public class SubscriptionPackage : BaseEntity
{
    public string Name { get; private set; } = string.Empty;
    public string NameAr { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public string? DescriptionAr { get; private set; }
    public int MaxEmployees { get; private set; }
    public decimal MonthlyPrice { get; private set; }
    public decimal YearlyPrice { get; private set; }
    public int TrialDays { get; private set; }
    public bool IsActive { get; private set; } = true;
    public List<string> Features { get; private set; } = new();

    private SubscriptionPackage() { }

    public static SubscriptionPackage Create(
        string name,
        string nameAr,
        int maxEmployees,
        decimal monthlyPrice,
        decimal yearlyPrice,
        int trialDays = 14)
    {
        return new SubscriptionPackage
        {
            Name = name,
            NameAr = nameAr,
            MaxEmployees = maxEmployees,
            MonthlyPrice = monthlyPrice,
            YearlyPrice = yearlyPrice,
            TrialDays = trialDays
        };
    }

    public void UpdatePricing(decimal monthlyPrice, decimal yearlyPrice)
    {
        MonthlyPrice = monthlyPrice;
        YearlyPrice = yearlyPrice;
    }

    public void SetFeatures(List<string> features)
    {
        Features = features;
    }

    public void Activate() => IsActive = true;
    public void Deactivate() => IsActive = false;

    public decimal GetYearlyDiscount()
    {
        var yearlyIfMonthly = MonthlyPrice * 12;
        return yearlyIfMonthly > 0 ? ((yearlyIfMonthly - YearlyPrice) / yearlyIfMonthly) * 100 : 0;
    }
}
