using System.ComponentModel.DataAnnotations.Schema;

namespace AdminDashboard.Api.Data;

[Table("StockTransactions")]
public class StockTransaction
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public int StoreId { get; set; }
    public decimal QuantityDelta { get; set; }
    public string TransactionType { get; set; } = "In"; // In, Out, Adjust
    public int? ReferenceOrderId { get; set; }
    public int? ReferenceOrderSupplierId { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public int? CreatedBy { get; set; }
}
