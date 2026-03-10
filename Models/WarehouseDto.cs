namespace AdminDashboard.Api.Models;

/// <summary>Tồn kho theo sản phẩm tại một cửa hàng.</summary>
public class ProductStockDto
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = "";
    public string ProductName { get; set; } = "";
    public int StoreId { get; set; }
    public string StoreName { get; set; } = "";
    public decimal Quantity { get; set; }
    public DateTime UpdatedAt { get; set; }
}

/// <summary>Phiếu nhập/xuất/điều chỉnh kho.</summary>
public class StockTransactionDto
{
    public int Id { get; set; }
    public int ProductId { get; set; }
    public string ProductName { get; set; } = "";
    public int StoreId { get; set; }
    public string StoreName { get; set; } = "";
    public decimal QuantityDelta { get; set; }
    public string TransactionType { get; set; } = ""; // In, Out, Adjust
    public int? ReferenceOrderId { get; set; }
    public int? ReferenceOrderSupplierId { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public int? CreatedBy { get; set; }
}

/// <summary>Tồn kho tại NCC (NCC xem hàng tồn).</summary>
public class SupplierStockDto
{
    public int SupplierId { get; set; }
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = "";
    public string ProductName { get; set; } = "";
    public decimal Quantity { get; set; }
    public DateTime UpdatedAt { get; set; }
}

/// <summary>Kết quả nhập kho từ đơn NCC.</summary>
public class StockInResultDto
{
    public int OrderSupplierId { get; set; }
    public int StoreId { get; set; }
    public int TransactionsCreated { get; set; }
    public string Message { get; set; } = "";
}
