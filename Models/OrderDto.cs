namespace AdminDashboard.Api.Models;

public class OrderItemDto
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = "";
    public int Quantity { get; set; }
    public string Unit { get; set; } = "";
    public decimal Price { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TaxPercent { get; set; }
    public decimal TaxAmount { get; set; }
}

public class ReceiveImageDto
{
    public int Id { get; set; }
    public string Type { get; set; } = ""; // received | invoice
    public string ImageUrl { get; set; } = "";
    public string? FileName { get; set; }
}

public class OrderSupplierDto
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int SupplierId { get; set; }
    public string SupplierName { get; set; } = "";
    public string Status { get; set; } = "";
    public DateTime? ExpectedDeliveryDate { get; set; }
    public DateTime? ActualDeliveryDate { get; set; }
    public DateTime? ConfirmDate { get; set; }
    public string? Note { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal TaxAmount { get; set; }
    public string PaymentStatus { get; set; } = "Unpaid";
    public decimal PaidAmount { get; set; }
    public DateTime? PaidDate { get; set; }
    public int? ReceivedBy { get; set; }
    public DateTime? ReceivedDate { get; set; }
    public List<OrderItemDto> OrderItems { get; set; } = new();
    public List<ReceiveImageDto> ReceiveImages { get; set; } = new();
}

public class OrderDto
{
    public int Id { get; set; }
    public int StoreId { get; set; }
    public string StoreName { get; set; } = "";
    public string Status { get; set; } = "";
    public DateTime OrderDate { get; set; }
    public DateTime? ExpectedDeliveryDate { get; set; }
    public int TotalItemCount { get; set; }
    public decimal TotalAmount { get; set; }
    public int CreatedBy { get; set; }
    public DateTime CreatedDate { get; set; }
    public List<OrderSupplierDto> OrderSuppliers { get; set; } = new();
}

public class OrderItemInputDto
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = "";
    public int Quantity { get; set; }
    public string Unit { get; set; } = "";
    public decimal Price { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal TaxPercent { get; set; }
    public decimal TaxAmount { get; set; }
}

public class OrderSupplierInputDto
{
    public int SupplierId { get; set; }
    public List<OrderItemInputDto> OrderItems { get; set; } = new();
}

public class OrderCreateDto
{
    public int StoreId { get; set; }
    public DateTime? ExpectedDeliveryDate { get; set; }
    public List<OrderSupplierInputDto> OrderSuppliers { get; set; } = new();
}

public class OrderSupplierStatusDto
{
    public string Status { get; set; } = ""; // Pending, Accepted, Rejected, Delivering, Delivered
    /// <summary>Ghi chú (vd. lý do từ chối Rejected).</summary>
    public string? Note { get; set; }
}

/// <summary>Admin cập nhật trạng thái đơn tổng.</summary>
public class OrderStatusDto
{
    public string Status { get; set; } = ""; // Pending, Rejected, Accepted, Completed
}
