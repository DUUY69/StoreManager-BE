using System.ComponentModel.DataAnnotations.Schema;

namespace AdminDashboard.Api.Data;

[Table("Users")]
public class User
{
    public int Id { get; set; }
    public string Email { get; set; } = "";
    public string? PasswordHash { get; set; }
    public string? PasswordSalt { get; set; }
    public byte PasswordHashVersion { get; set; } = 1;
    public string Name { get; set; } = "";
    public string? Phone { get; set; }
    public string Role { get; set; } = "";
    public int? StoreId { get; set; }
    public int? SupplierId { get; set; }
    public string Status { get; set; } = "Active";
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
