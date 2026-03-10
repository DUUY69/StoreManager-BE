using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminDashboard.Api.Data;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/supplier-orders")]
[Authorize]
public class SupplierOrdersController : ControllerBase
{
    private readonly AppDbContext _db;

    public SupplierOrdersController(AppDbContext db)
    {
        _db = db;
    }

    private int? GetCurrentSupplierId()
    {
        var raw = User.FindFirstValue("supplierId") ?? User.FindFirstValue("SupplierId");
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

    /// <summary>Danh sách đơn con của NCC đang đăng nhập. Query: status, dateFrom, dateTo.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(List<OrderSupplierDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll([FromQuery] string? status, [FromQuery] string? dateFrom, [FromQuery] string? dateTo)
    {
        var supplierId = GetCurrentSupplierId();
        if (supplierId == null)
            return Ok(new List<OrderSupplierDto>());

        var query = _db.OrderSuppliers
            .AsNoTracking()
            .Include(x => x.Order)
            .Include(x => x.Supplier)
            .Include(x => x.OrderItems)
            .Where(x => x.SupplierId == supplierId.Value);

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(x => x.Status == status);
        if (DateTime.TryParse(dateFrom, out var df))
            query = query.Where(x => x.Order != null && x.Order.OrderDate >= df);
        if (DateTime.TryParse(dateTo, out var dt))
            query = query.Where(x => x.Order != null && x.Order.OrderDate <= dt.AddDays(1));

        var list = await query
            .OrderByDescending(x => x.Id)
            .Select(os => new OrderSupplierDto
            {
                Id = os.Id,
                OrderId = os.OrderId,
                SupplierId = os.SupplierId,
                SupplierName = os.Supplier != null ? os.Supplier.Name : "",
                Status = os.Status,
                ExpectedDeliveryDate = os.ExpectedDeliveryDate,
                ActualDeliveryDate = os.ActualDeliveryDate,
                ConfirmDate = os.ConfirmDate,
                Note = os.Note,
                OrderItems = os.OrderItems.Select(oi => new OrderItemDto
                {
                    Id = oi.Id,
                    ProductId = oi.ProductId,
                    ProductName = oi.ProductName,
                    Quantity = oi.Quantity,
                    Unit = oi.Unit,
                    Price = oi.Price
                }).ToList(),
                ReceiveImages = new List<ReceiveImageDto>()
            })
            .ToListAsync();
        return Ok(list);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(OrderSupplierDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var supplierId = GetCurrentSupplierId();
        if (supplierId == null) return NotFound();

        var os = await _db.OrderSuppliers
            .AsNoTracking()
            .Include(x => x.Supplier)
            .Include(x => x.OrderItems)
            .FirstOrDefaultAsync(x => x.Id == id && x.SupplierId == supplierId.Value);
        if (os == null) return NotFound();

        var dto = new OrderSupplierDto
        {
            Id = os.Id,
            OrderId = os.OrderId,
            SupplierId = os.SupplierId,
            SupplierName = os.Supplier?.Name ?? "",
            Status = os.Status,
            ExpectedDeliveryDate = os.ExpectedDeliveryDate,
            ActualDeliveryDate = os.ActualDeliveryDate,
            ConfirmDate = os.ConfirmDate,
            Note = os.Note,
            OrderItems = os.OrderItems.Select(oi => new OrderItemDto
            {
                Id = oi.Id,
                ProductId = oi.ProductId,
                ProductName = oi.ProductName,
                Quantity = oi.Quantity,
                Unit = oi.Unit,
                Price = oi.Price
            }).ToList(),
            ReceiveImages = new List<ReceiveImageDto>()
        };
        return Ok(dto);
    }

    /// <summary>NCC cập nhật trạng thái đơn con (Pending, Accepted, Rejected, Delivering, Delivered). Lưu DB. Chỉ được sửa đơn thuộc NCC đang đăng nhập.</summary>
    [HttpPatch("{id:int}/status")]
    [ProducesResponseType(typeof(OrderSupplierDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status403Forbidden)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] OrderSupplierStatusDto? dto)
    {
        var supplierId = GetCurrentSupplierId();
        if (supplierId == null)
            return StatusCode(403, new { message = "Tài khoản không phải NCC hoặc thiếu supplierId." });

        if (dto == null)
            return BadRequest(new { message = "Body phải là JSON với trường status (vd: {\"status\":\"Accepted\"})." });

        var newStatus = (dto.Status ?? "").Trim();
        if (string.IsNullOrEmpty(newStatus))
            return BadRequest(new { message = "Status không được để trống." });

        var allowed = new[] { "Pending", "Accepted", "Rejected", "Delivering", "Delivered" };
        if (!allowed.Contains(newStatus, StringComparer.OrdinalIgnoreCase))
            return BadRequest(new { message = "Status phải là một trong: " + string.Join(", ", allowed) });

        var os = await _db.OrderSuppliers
            .Include(x => x.Supplier)
            .FirstOrDefaultAsync(x => x.Id == id && x.SupplierId == supplierId.Value);
        if (os == null)
            return NotFound(new { message = "Không tìm thấy đơn NCC hoặc không thuộc quyền NCC của bạn." });

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
}
