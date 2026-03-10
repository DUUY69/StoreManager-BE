using System.ComponentModel.DataAnnotations.Schema;

namespace AdminDashboard.Api.Data;

[Table("Products")]
public class Product
{
    public int Id { get; set; }
    public string Code { get; set; } = "";
    public string Name { get; set; } = "";
    public int SupplierId { get; set; }
    public int CategoryId { get; set; }
    public string Unit { get; set; } = "cái";
    public decimal Price { get; set; }
    public string Status { get; set; } = "Active";
    public int? CreatedBy { get; set; }
    public int? UpdatedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
