using System.ComponentModel.DataAnnotations.Schema;

namespace AdminDashboard.Api.Data;

[Table("Orders")]
public class Order
{
    public int Id { get; set; }
    public int StoreId { get; set; }
    public string Status { get; set; } = "";
    public DateTime OrderDate { get; set; }
    public DateTime? OverallExpectedDate { get; set; }
    public DateTime? DueDate { get; set; }
    public DateTime? CancelAfterDate { get; set; }
    public int TotalItemCount { get; set; }
    public decimal TotalAmount { get; set; }
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public DateTime? LastStatusChangedDate { get; set; }
    public string? CancelReason { get; set; }
    public int? CancelledBy { get; set; }
    public bool IsDeleted { get; set; }

    [ForeignKey(nameof(StoreId))]
    public Store? Store { get; set; }
    public ICollection<OrderSupplier> OrderSuppliers { get; set; } = new List<OrderSupplier>();
}
