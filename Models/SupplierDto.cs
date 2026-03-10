namespace AdminDashboard.Api.Models;

public class SupplierDto
{
    public int Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string? Contact { get; set; }
    public string? Email { get; set; }
    public string? Address { get; set; }
    public string Status { get; set; } = "Active";
}

public class SupplierCreateUpdateDto
{
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public string? Contact { get; set; }
    public string? Email { get; set; }
    public string? Address { get; set; }
    public string Status { get; set; } = "Active";
}
