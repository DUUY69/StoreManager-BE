using System.ComponentModel.DataAnnotations.Schema;

namespace AdminDashboard.Api.Data;

[Table("OrderSuppliers")]
public class OrderSupplier
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int SupplierId { get; set; }
    public string Status { get; set; } = "";
    public DateTime? ExpectedDeliveryDate { get; set; }
    public DateTime? ActualDeliveryDate { get; set; }
    public DateTime? ConfirmDate { get; set; }
    public string? Note { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal DiscountPercent { get; set; }
    public decimal TaxAmount { get; set; }
    public string PaymentStatus { get; set; } = "Unpaid";
    public decimal PaidAmount { get; set; }
    public DateTime? PaidDate { get; set; }
    public int? ReceivedBy { get; set; }
    public DateTime? ReceivedDate { get; set; }

    [ForeignKey(nameof(OrderId))]
    public Order? Order { get; set; }
    [ForeignKey(nameof(SupplierId))]
    public Supplier? Supplier { get; set; }
    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    public ICollection<ReceiveImage> ReceiveImages { get; set; } = new List<ReceiveImage>();
}
