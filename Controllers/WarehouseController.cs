using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/warehouse")]
[Authorize]
public class WarehouseController : ControllerBase
{
    private int? GetCurrentSupplierId()
    {
        var raw = User.FindFirstValue("supplierId") ?? User.FindFirstValue("SupplierId");
        return int.TryParse(raw, out var sid) ? sid : null;
    }

    /// <summary>Tồn kho tại NCC. Chỉ SupplierUser; supplierId lấy từ token.</summary>
    [HttpGet("supplier-stock")]
    [ProducesResponseType(typeof(List<SupplierStockDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    public IActionResult GetSupplierStock()
    {
        var supplierId = GetCurrentSupplierId();
        if (supplierId == null)
            return StatusCode(403, new { message = "Chỉ tài khoản NCC được xem tồn kho." });

        var role = User.FindFirstValue(ClaimTypes.Role) ?? User.FindFirstValue("role");
        if (!string.Equals(role, "SupplierUser", StringComparison.OrdinalIgnoreCase))
            return StatusCode(403, new { message = "Chỉ NCC được xem tồn kho tại đây." });

        var mockBySupplier = new Dictionary<int, List<SupplierStockDto>>
        {
            [1] = new()
            {
                new() { SupplierId = 1, ProductId = 1, ProductCode = "CF001", ProductName = "Cà phê Arabica 1kg", Quantity = 200, UpdatedAt = DateTime.UtcNow },
                new() { SupplierId = 1, ProductId = 2, ProductCode = "CF002", ProductName = "Cà phê Robusta 500g", Quantity = 150, UpdatedAt = DateTime.UtcNow },
                new() { SupplierId = 1, ProductId = 3, ProductCode = "CF003", ProductName = "Espresso blend 500g", Quantity = 80, UpdatedAt = DateTime.UtcNow },
            },
            [2] = new()
            {
                new() { SupplierId = 2, ProductId = 5, ProductCode = "VT005", ProductName = "Sữa tươi có đường 1L", Quantity = 100, UpdatedAt = DateTime.UtcNow },
                new() { SupplierId = 2, ProductId = 6, ProductCode = "VT006", ProductName = "Sữa đặc Ông Thọ 380g", Quantity = 60, UpdatedAt = DateTime.UtcNow },
            },
            [3] = new()
            {
                new() { SupplierId = 3, ProductId = 8, ProductCode = "SY008", ProductName = "Syrup Caramel Monin 700ml", Quantity = 50, UpdatedAt = DateTime.UtcNow },
                new() { SupplierId = 3, ProductId = 9, ProductCode = "SY009", ProductName = "Syrup Chocolate Monin 700ml", Quantity = 45, UpdatedAt = DateTime.UtcNow },
            },
        };
        var list = mockBySupplier.TryGetValue(supplierId.Value, out var rows) ? rows : new List<SupplierStockDto>();
        return Ok(list);
    }

    /// <summary>Danh sách tồn kho theo cửa hàng. Admin/StoreUser (không dùng cho NCC).</summary>
    [HttpGet("stock")]
    [ProducesResponseType(typeof(List<ProductStockDto>), StatusCodes.Status200OK)]
    public IActionResult GetStock([FromQuery] int? storeId)
    {
        var list = new List<ProductStockDto>
        {
            new() { ProductId = 1, ProductCode = "CF001", ProductName = "Cà phê Arabica 1kg", StoreId = 1, StoreName = "Cafe Q1", Quantity = 50, UpdatedAt = DateTime.UtcNow },
            new() { ProductId = 2, ProductCode = "CF002", ProductName = "Cà phê Robusta 500g", StoreId = 1, StoreName = "Cafe Q1", Quantity = 30, UpdatedAt = DateTime.UtcNow },
        };
        if (storeId.HasValue)
            list = list.Where(x => x.StoreId == storeId.Value).ToList();
        return Ok(list);
    }

    /// <summary>Lịch sử phiếu nhập/xuất/điều chỉnh kho.</summary>
    [HttpGet("transactions")]
    [ProducesResponseType(typeof(List<StockTransactionDto>), StatusCodes.Status200OK)]
    public IActionResult GetTransactions([FromQuery] int? storeId, [FromQuery] DateTime? dateFrom, [FromQuery] DateTime? dateTo)
    {
        var list = new List<StockTransactionDto>
        {
            new() { Id = 1, ProductId = 1, ProductName = "Cà phê Arabica", StoreId = 1, StoreName = "Cafe Q1", QuantityDelta = 10, TransactionType = "In", ReferenceOrderId = 1, ReferenceOrderSupplierId = 101, CreatedAt = DateTime.UtcNow.AddDays(-1) },
            new() { Id = 2, ProductId = 2, ProductName = "Cà phê Robusta", StoreId = 1, StoreName = "Cafe Q1", QuantityDelta = 5, TransactionType = "In", ReferenceOrderId = 1, ReferenceOrderSupplierId = 101, CreatedAt = DateTime.UtcNow.AddDays(-1) },
        };
        if (storeId.HasValue) list = list.Where(x => x.StoreId == storeId.Value).ToList();
        if (dateFrom.HasValue) list = list.Where(x => x.CreatedAt.Date >= dateFrom.Value.Date).ToList();
        if (dateTo.HasValue) list = list.Where(x => x.CreatedAt.Date <= dateTo.Value.Date).ToList();
        return Ok(list.OrderByDescending(x => x.CreatedAt).ToList());
    }
}
