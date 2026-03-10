using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminDashboard.Api.Data;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/order-suppliers")]
[Authorize]
public class OrderSuppliersController : ControllerBase
{
    private readonly AppDbContext _db;
    private readonly IWebHostEnvironment _env;

    public OrderSuppliersController(AppDbContext db, IWebHostEnvironment env)
    {
        _db = db;
        _env = env;
    }

    private int? GetCurrentUserId()
    {
        var sub = User.FindFirstValue(ClaimTypes.NameIdentifier) ?? User.FindFirstValue("sub");
        return int.TryParse(sub, out var uid) ? uid : null;
    }

    private int? GetCurrentStoreId()
    {
        var raw = User.FindFirstValue("storeId") ?? User.FindFirstValue("StoreId");
        return int.TryParse(raw, out var sid) ? sid : null;
    }

    /// <summary>Nếu tất cả đơn NCC đã Delivered hoặc Rejected thì chuyển đơn tổng sang Completed.</summary>
    private async Task TryCompleteParentOrderAsync(int orderId)
    {
        var anyNotDone = await _db.OrderSuppliers
            .AnyAsync(x => x.OrderId == orderId && x.Status != "Delivered" && x.Status != "Rejected");
        if (anyNotDone) return;
        var order = await _db.Orders.FindAsync(orderId);
        if (order == null || order.IsDeleted) return;
        order.Status = "Completed";
        order.LastStatusChangedDate = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    /// <summary>Admin cập nhật trạng thái đơn NCC (khi NCC không dùng hệ thống). Chỉ Admin.</summary>
    [HttpPatch("{id:int}/status")]
    [ProducesResponseType(typeof(OrderSupplierDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] OrderSupplierStatusDto? dto)
    {
        var role = User.FindFirstValue(ClaimTypes.Role) ?? User.FindFirstValue("role");
        if (string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase) == false)
            return StatusCode(403, new { message = "Chỉ Admin được cập nhật trạng thái đơn NCC từ trang đơn hàng." });

        if (dto == null)
            return BadRequest("Body phải là JSON với trường status (vd: {\"status\":\"Accepted\"}).");

        var newStatus = (dto.Status ?? "").Trim();
        if (string.IsNullOrEmpty(newStatus)) return BadRequest("Status không được để trống.");

        var allowedStatuses = new[] { "Pending", "Accepted", "Rejected", "Delivering", "Delivered" };
        if (!allowedStatuses.Contains(newStatus, StringComparer.OrdinalIgnoreCase))
            return BadRequest("Status phải là một trong: " + string.Join(", ", allowedStatuses));

        var os = await _db.OrderSuppliers
            .Include(x => x.Supplier)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (os == null) return NotFound();

        os.Status = newStatus;
        os.Note = dto.Note;
        if (string.Equals(newStatus, "Accepted", StringComparison.OrdinalIgnoreCase))
            os.ConfirmDate = DateTime.UtcNow.Date;
        if (string.Equals(newStatus, "Delivered", StringComparison.OrdinalIgnoreCase))
            os.ActualDeliveryDate = os.ActualDeliveryDate ?? DateTime.UtcNow.Date;

        try
        {
            await _db.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi lưu DB: " + ex.Message });
        }

        if (string.Equals(newStatus, "Delivered", StringComparison.OrdinalIgnoreCase))
            await TryCompleteParentOrderAsync(os.OrderId);

        var result = new OrderSupplierDto
        {
            Id = os.Id,
            OrderId = os.OrderId,
            SupplierId = os.SupplierId,
            SupplierName = os.Supplier?.Name ?? "",
            Status = os.Status,
            Note = os.Note,
            ExpectedDeliveryDate = os.ExpectedDeliveryDate,
            ActualDeliveryDate = os.ActualDeliveryDate,
            ConfirmDate = os.ConfirmDate,
            TotalAmount = os.TotalAmount,
            TaxAmount = os.TaxAmount,
            PaymentStatus = os.PaymentStatus,
            PaidAmount = os.PaidAmount,
            PaidDate = os.PaidDate,
            ReceivedBy = os.ReceivedBy,
            ReceivedDate = os.ReceivedDate,
            OrderItems = new List<OrderItemDto>(),
            ReceiveImages = new List<ReceiveImageDto>()
        };
        return Ok(result);
    }

    /// <summary>Store xác nhận đã nhận hàng. Ảnh (received[], invoice[]) không bắt buộc; nếu có thì lưu vào ReceiveImages và cập nhật trạng thái đơn NCC thành Delivered.</summary>
    [HttpPatch("{id:int}/confirm-receive")]
    [ProducesResponseType(typeof(OrderSupplierDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ConfirmReceive(int id, IFormFile[]? received, IFormFile[]? invoice)
    {
        var userId = GetCurrentUserId();
        var storeId = GetCurrentStoreId();
        if (storeId == null)
            return StatusCode(403, new { message = "Chỉ tài khoản Store (cửa hàng) được xác nhận nhận hàng." });

        var os = await _db.OrderSuppliers
            .Include(x => x.Order)
            .Include(x => x.Supplier)
            .Include(x => x.OrderItems)
            .Include(x => x.ReceiveImages)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (os == null)
            return NotFound(new { message = "Không tìm thấy đơn NCC." });
        if (os.Order == null || os.Order.StoreId != storeId.Value)
            return StatusCode(403, new { message = "Đơn hàng không thuộc cửa hàng của bạn." });

        var uploadDir = Path.Combine(_env.WebRootPath ?? Path.Combine(_env.ContentRootPath, "wwwroot"), "uploads", "receive");
        try
        {
            if (!Directory.Exists(uploadDir))
                Directory.CreateDirectory(uploadDir);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Không tạo được thư mục lưu ảnh: " + ex.Message });
        }

        var savedImages = new List<ReceiveImageDto>();
        async Task SaveFiles(IFormFile[]? files, string type)
        {
            if (files == null || files.Length == 0) return;
            for (var i = 0; i < files.Length; i++)
            {
                var file = files[i];
                if (file.Length == 0) continue;
                var ext = Path.GetExtension(file.FileName);
                if (string.IsNullOrEmpty(ext)) ext = ".jpg";
                var fileName = $"{id}_{type}_{i}_{Guid.NewGuid():N}{ext}";
                var fullPath = Path.Combine(uploadDir, fileName);
                try
                {
                    await using (var stream = new FileStream(fullPath, FileMode.Create))
                        await file.CopyToAsync(stream);
                }
                catch (Exception ex)
                {
                    throw new InvalidOperationException("Lưu ảnh thất bại: " + ex.Message);
                }
                var relativeUrl = $"/uploads/receive/{fileName}";
                var ri = new ReceiveImage
                {
                    OrderSupplierId = id,
                    Type = type,
                    ImageUrl = relativeUrl,
                    FileName = file.FileName,
                    CreatedAt = DateTime.UtcNow
                };
                _db.ReceiveImages.Add(ri);
                await _db.SaveChangesAsync();
                savedImages.Add(new ReceiveImageDto { Id = ri.Id, Type = type, ImageUrl = relativeUrl, FileName = ri.FileName });
            }
        }

        try
        {
            await SaveFiles(received, "received");
            await SaveFiles(invoice, "invoice");
        }
        catch (InvalidOperationException ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }

        os.Status = "Delivered";
        os.ActualDeliveryDate = os.ActualDeliveryDate ?? DateTime.UtcNow.Date;
        os.ReceivedBy = userId;
        os.ReceivedDate = DateTime.UtcNow;

        try
        {
            _db.Entry(os).Property(nameof(OrderSupplier.Status)).IsModified = true;
            _db.Entry(os).Property(nameof(OrderSupplier.ActualDeliveryDate)).IsModified = true;
            _db.Entry(os).Property(nameof(OrderSupplier.ReceivedBy)).IsModified = true;
            _db.Entry(os).Property(nameof(OrderSupplier.ReceivedDate)).IsModified = true;
            await _db.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi cập nhật trạng thái: " + ex.Message });
        }

        await TryCompleteParentOrderAsync(os.OrderId);

        var existingImages = await _db.ReceiveImages
            .Where(x => x.OrderSupplierId == id)
            .Select(x => new ReceiveImageDto { Id = x.Id, Type = x.Type, ImageUrl = x.ImageUrl, FileName = x.FileName })
            .ToListAsync();

        var result = new OrderSupplierDto
        {
            Id = os.Id,
            OrderId = os.OrderId,
            SupplierId = os.SupplierId,
            SupplierName = os.Supplier?.Name ?? "",
            Status = os.Status,
            Note = os.Note,
            ExpectedDeliveryDate = os.ExpectedDeliveryDate,
            ActualDeliveryDate = os.ActualDeliveryDate,
            ConfirmDate = os.ConfirmDate,
            TotalAmount = os.TotalAmount,
            TaxAmount = os.TaxAmount,
            PaymentStatus = os.PaymentStatus,
            PaidAmount = os.PaidAmount,
            PaidDate = os.PaidDate,
            ReceivedBy = os.ReceivedBy,
            ReceivedDate = os.ReceivedDate,
            OrderItems = os.OrderItems.Select(oi => new OrderItemDto
            {
                Id = oi.Id,
                ProductId = oi.ProductId,
                ProductName = oi.ProductName,
                Quantity = oi.Quantity,
                Unit = oi.Unit,
                Price = oi.Price
            }).ToList(),
            ReceiveImages = existingImages
        };
        return Ok(result);
    }

    /// <summary>Nhập kho: tạo phiếu nhập (StockTransactions In) từ các dòng đơn OrderSupplier, cập nhật ProductStock. Gọi khi Store đã nhận hàng từ NCC.</summary>
    [HttpPost("{id:int}/stock-in")]
    [ProducesResponseType(typeof(StockInResultDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> StockIn(int id)
    {
        var role = User.FindFirstValue(ClaimTypes.Role) ?? User.FindFirstValue("role");
        var userId = GetCurrentUserId();
        var storeId = GetCurrentStoreId();

        var os = await _db.OrderSuppliers
            .Include(x => x.Order)
            .Include(x => x.OrderItems)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (os == null) return NotFound(new { message = "Không tìm thấy đơn NCC." });
        if (os.Order == null) return BadRequest(new { message = "Đơn NCC không gắn với đơn tổng." });

        // Chỉ Admin hoặc StoreUser của đúng cửa hàng mới được nhập kho
        var isAdmin = string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase);
        var isStoreOfOrder = storeId.HasValue && os.Order.StoreId == storeId.Value;
        if (!isAdmin && !isStoreOfOrder)
            return StatusCode(403, new { message = "Chỉ Admin hoặc cửa hàng của đơn mới được nhập kho." });

        // Chỉ cho phép khi đơn NCC đã Delivered / Completed / Partial (đã giao hoặc giao thiếu)
        var status = (os.Status ?? "").Trim();
        var allowedStatuses = new[] { "Delivered", "Completed", "Partial" };
        if (!allowedStatuses.Contains(status, StringComparer.OrdinalIgnoreCase))
            return BadRequest(new { message = "Chỉ được nhập kho khi đơn NCC đã Giao hoàn thành / Hoàn thành / Giao thiếu. Trạng thái hiện tại: " + (string.IsNullOrEmpty(status) ? "—" : status) });

        // Tránh nhập trùng: nếu đã có phiếu nhập từ đơn NCC này thì báo lỗi
        var alreadyStockIn = await _db.StockTransactions.AnyAsync(x => x.ReferenceOrderSupplierId == id);
        if (alreadyStockIn)
            return BadRequest(new { message = "Đơn NCC này đã được nhập kho rồi." });

        var orderId = os.OrderId;
        var storeIdForStock = os.Order.StoreId;
        var supplierName = (await _db.Suppliers.FindAsync(os.SupplierId))?.Name ?? "";

        var now = DateTime.UtcNow;
        var notePrefix = $"Nhập kho từ đơn #{os.OrderId} - NCC {supplierName}";
        var transactions = new List<StockTransaction>();
        foreach (var oi in os.OrderItems)
        {
            transactions.Add(new StockTransaction
            {
                ProductId = oi.ProductId,
                StoreId = storeIdForStock,
                QuantityDelta = oi.Quantity,
                TransactionType = "In",
                ReferenceOrderId = orderId,
                ReferenceOrderSupplierId = id,
                Note = $"{notePrefix} - {oi.ProductName} x{oi.Quantity}",
                CreatedAt = now,
                CreatedBy = userId
            });
        }

        await _db.StockTransactions.AddRangeAsync(transactions);
        try
        {
            await _db.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Lỗi lưu phiếu nhập kho: " + ex.Message });
        }

        var result = new StockInResultDto
        {
            OrderSupplierId = id,
            StoreId = storeIdForStock,
            TransactionsCreated = transactions.Count,
            Message = "Đã nhập kho theo đơn NCC."
        };
        return Ok(result);
    }
}
