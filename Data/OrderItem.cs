using System.ComponentModel.DataAnnotations.Schema;

namespace AdminDashboard.Api.Data;

[Table("OrderItems")]
public class OrderItem
{
    public int Id { get; set; }
    public int OrderSupplierId { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = "";
    public int Quantity { get; set; }
    public string Unit { get; set; } = "";
    public decimal Price { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TaxPercent { get; set; }
    public decimal TaxAmount { get; set; }

    [ForeignKey(nameof(OrderSupplierId))]
    public OrderSupplier? OrderSupplier { get; set; }
}
