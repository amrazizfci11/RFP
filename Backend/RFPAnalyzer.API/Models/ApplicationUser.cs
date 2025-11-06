using Microsoft.AspNetCore.Identity;

namespace RFPAnalyzer.API.Models;

public class ApplicationUser : IdentityUser
{
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public ICollection<RFPDocument> Documents { get; set; } = new List<RFPDocument>();
}
