using System.ComponentModel.DataAnnotations.Schema;

namespace AdminDashboard.Api.Data;

[Table("ReceiveImages")]
public class ReceiveImage
{
    public int Id { get; set; }
    public int OrderSupplierId { get; set; }
    public string Type { get; set; } = ""; // "received" | "invoice"
    public string ImageUrl { get; set; } = "";
    public string? FileName { get; set; }
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [ForeignKey(nameof(OrderSupplierId))]
    public OrderSupplier? OrderSupplier { get; set; }
}
