using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminDashboard.Api.Data;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/orders")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly AppDbContext _db;

    public OrdersController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>Danh sách đơn. Query: status, storeId, supplierId, dateFrom, dateTo. No-cache để F5/reload luôn lấy dữ liệu mới.</summary>
    [HttpGet]
    [ResponseCache(Location = ResponseCacheLocation.None, NoStore = true, Duration = 0)]
    [ProducesResponseType(typeof(List<OrderDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll([FromQuery] string? status, [FromQuery] int? storeId, [FromQuery] int? supplierId, [FromQuery] string? dateFrom, [FromQuery] string? dateTo)
    {
        var query = _db.Orders
            .AsNoTracking()
            .Where(o => !o.IsDeleted)
            .Include(o => o.Store)
            .Include(o => o.OrderSuppliers)
                .ThenInclude(os => os.Supplier)
            .Include(o => o.OrderSuppliers)
                .ThenInclude(os => os.OrderItems)
            .Include(o => o.OrderSuppliers)
                .ThenInclude(os => os.ReceiveImages)
            .OrderByDescending(o => o.OrderDate)
            .ThenByDescending(o => o.Id)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(o => o.Status == status);
        if (storeId.HasValue)
            query = query.Where(o => o.StoreId == storeId.Value);
        if (supplierId.HasValue)
            query = query.Where(o => o.OrderSuppliers.Any(os => os.SupplierId == supplierId.Value));
        if (!string.IsNullOrWhiteSpace(dateFrom) && DateTime.TryParse(dateFrom, out var df))
            query = query.Where(o => o.OrderDate >= df.Date);
        if (!string.IsNullOrWhiteSpace(dateTo) && DateTime.TryParse(dateTo, out var dt))
            query = query.Where(o => o.OrderDate <= dt.Date);

        var list = await query.ToListAsync();

        var result = list.Select(o => new OrderDto
        {
            Id = o.Id,
            StoreId = o.StoreId,
            StoreName = o.Store?.Name ?? "",
            Status = o.Status,
            OrderDate = o.OrderDate,
            ExpectedDeliveryDate = o.OverallExpectedDate,
            TotalItemCount = o.TotalItemCount,
            TotalAmount = o.TotalAmount,
            CreatedBy = o.CreatedBy,
            CreatedDate = o.CreatedDate,
            OrderSuppliers = o.OrderSuppliers.Select(os => new OrderSupplierDto
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
                    Price = oi.Price,
                    DiscountAmount = oi.DiscountAmount,
                    TaxPercent = oi.TaxPercent,
                    TaxAmount = oi.TaxAmount
                }).ToList(),
                ReceiveImages = (os.ReceiveImages ?? new List<ReceiveImage>()).Select(ri => new ReceiveImageDto { Id = ri.Id, Type = ri.Type, ImageUrl = ri.ImageUrl, FileName = ri.FileName }).ToList()
            }).ToList()
        }).ToList();

        return Ok(result);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var o = await _db.Orders
            .AsNoTracking()
            .Include(x => x.Store)
            .Include(x => x.OrderSuppliers)
                .ThenInclude(os => os.Supplier)
            .Include(x => x.OrderSuppliers)
                .ThenInclude(os => os.OrderItems)
            .Include(x => x.OrderSuppliers)
                .ThenInclude(os => os.ReceiveImages)
            .FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted);
        if (o == null) return NotFound();

        var dto = new OrderDto
        {
            Id = o.Id,
            StoreId = o.StoreId,
            StoreName = o.Store?.Name ?? "",
            Status = o.Status,
            OrderDate = o.OrderDate,
            ExpectedDeliveryDate = o.OverallExpectedDate,
            TotalItemCount = o.TotalItemCount,
            TotalAmount = o.TotalAmount,
            CreatedBy = o.CreatedBy,
            CreatedDate = o.CreatedDate,
            OrderSuppliers = o.OrderSuppliers.Select(os => new OrderSupplierDto
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
                    Price = oi.Price,
                    DiscountAmount = oi.DiscountAmount,
                    TaxPercent = oi.TaxPercent,
                    TaxAmount = oi.TaxAmount
                }).ToList(),
                ReceiveImages = (os.ReceiveImages ?? new List<ReceiveImage>()).Select(ri => new ReceiveImageDto { Id = ri.Id, Type = ri.Type, ImageUrl = ri.ImageUrl, FileName = ri.FileName }).ToList()
            }).ToList()
        };
        return Ok(dto);
    }

    /// <summary>Tạo đơn mới (kèm orderSuppliers và orderItems). Lưu vào DB.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] OrderCreateDto dto)
    {
        if (dto == null || dto.OrderSuppliers == null || dto.OrderSuppliers.Count == 0)
            return BadRequest(new { message = "Thiếu thông tin đơn hoặc danh sách NCC." });

        if (dto.StoreId <= 0)
            return BadRequest(new { message = "Vui lòng chọn cửa hàng (StoreId không hợp lệ)." });

        var storeExists = await _db.Stores.AnyAsync(s => s.Id == dto.StoreId);
        if (!storeExists)
            return BadRequest(new { message = "Cửa hàng không tồn tại. Kiểm tra lại StoreId." });

        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var createdBy = int.TryParse(userIdClaim, out var uid) ? uid : 0;
        if (createdBy <= 0)
            return BadRequest(new { message = "Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại." });

        var totalItems = dto.OrderSuppliers.Sum(os => os.OrderItems?.Sum(oi => oi.Quantity) ?? 0);
        if (totalItems == 0)
            return BadRequest(new { message = "Đơn phải có ít nhất một sản phẩm." });

        var order = new Order
        {
            StoreId = dto.StoreId,
            Status = "Pending",
            OrderDate = DateTime.UtcNow.Date,
            OverallExpectedDate = dto.ExpectedDeliveryDate,
            TotalItemCount = (int)totalItems,
            TotalAmount = 0,
            CreatedBy = createdBy,
            CreatedDate = DateTime.UtcNow,
            IsDeleted = false
        };

        foreach (var osDto in dto.OrderSuppliers)
        {
            if (osDto.OrderItems == null || osDto.OrderItems.Count == 0) continue;
            var supplier = await _db.Suppliers.AsNoTracking().FirstOrDefaultAsync(s => s.Id == osDto.SupplierId);
            var os = new OrderSupplier
            {
                SupplierId = osDto.SupplierId,
                Status = "Pending",
                Order = order,
                TotalAmount = 0,
                PaymentStatus = "Unpaid"
            };
            foreach (var oiDto in osDto.OrderItems)
            {
                os.OrderItems.Add(new OrderItem
                {
                    ProductId = oiDto.ProductId,
                    ProductName = oiDto.ProductName ?? "",
                    Quantity = oiDto.Quantity,
                    Unit = oiDto.Unit ?? "",
                    Price = oiDto.Price,
                    DiscountAmount = oiDto.DiscountAmount,
                    TaxPercent = oiDto.TaxPercent,
                    TaxAmount = oiDto.TaxAmount
                });
            }
            order.OrderSuppliers.Add(os);
        }

        if (order.OrderSuppliers.Count == 0)
            return BadRequest(new { message = "Không có dòng sản phẩm hợp lệ." });

        _db.Orders.Add(order);
        try
        {
            await _db.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            // Lấy lỗi SQL thực tế (FK, constraint, trigger...) nếu có
            var msg = ex.Message;
            var inner = ex;
            while (inner?.InnerException != null)
            {
                inner = inner.InnerException;
                if (inner is Microsoft.Data.SqlClient.SqlException sqlEx)
                    msg = sqlEx.Message;
                else if (!string.IsNullOrEmpty(inner.Message) && !inner.Message.Contains("See the inner exception"))
                    msg = inner.Message;
            }
            return BadRequest(new { message = "Lỗi lưu đơn: " + msg });
        }

        var created = await _db.Orders
            .AsNoTracking()
            .Include(o => o.Store)
            .Include(o => o.OrderSuppliers)
                .ThenInclude(os => os.Supplier)
            .Include(o => o.OrderSuppliers)
                .ThenInclude(os => os.OrderItems)
            .Include(o => o.OrderSuppliers)
                .ThenInclude(os => os.ReceiveImages)
            .FirstOrDefaultAsync(o => o.Id == order.Id);
        if (created == null)
            return CreatedAtAction(nameof(GetById), new { id = order.Id }, new OrderDto { Id = order.Id, StoreId = order.StoreId, Status = order.Status, OrderDate = order.OrderDate, TotalItemCount = order.TotalItemCount, CreatedBy = order.CreatedBy, CreatedDate = order.CreatedDate });

        var result = new OrderDto
        {
            Id = created.Id,
            StoreId = created.StoreId,
            StoreName = created.Store?.Name ?? "",
            Status = created.Status,
            OrderDate = created.OrderDate,
            ExpectedDeliveryDate = created.OverallExpectedDate,
            TotalItemCount = created.TotalItemCount,
            TotalAmount = created.TotalAmount,
            CreatedBy = created.CreatedBy,
            CreatedDate = created.CreatedDate,
            OrderSuppliers = created.OrderSuppliers.Select(os => new OrderSupplierDto
            {
                Id = os.Id,
                OrderId = os.OrderId,
                SupplierId = os.SupplierId,
                SupplierName = os.Supplier?.Name ?? "",
                Status = os.Status,
                OrderItems = os.OrderItems.Select(oi => new OrderItemDto
                {
                    Id = oi.Id,
                    ProductId = oi.ProductId,
                    ProductName = oi.ProductName,
                    Quantity = oi.Quantity,
                    Unit = oi.Unit,
                    Price = oi.Price,
                    DiscountAmount = oi.DiscountAmount,
                    TaxPercent = oi.TaxPercent,
                    TaxAmount = oi.TaxAmount
                }).ToList(),
                ReceiveImages = (os.ReceiveImages ?? new List<ReceiveImage>()).Select(ri => new ReceiveImageDto { Id = ri.Id, Type = ri.Type, ImageUrl = ri.ImageUrl, FileName = ri.FileName }).ToList()
            }).ToList()
        };
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }

    /// <summary>Admin chấp nhận đơn tổng (Pending → Accepted). Các đơn NCC vẫn Chờ để từng NCC tự chấp nhận/từ chối.</summary>
    [HttpPatch("{id:int}/accept")]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Accept(int id)
    {
        var o = await _db.Orders.FindAsync(id);
        if (o == null || o.IsDeleted) return NotFound();
        if (o.Status != "Pending") return Ok(await GetByIdDto(id));
        o.Status = "Accepted";
        o.LastStatusChangedDate = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(await GetByIdDto(id));
    }

    /// <summary>Admin từ chối đơn (Pending → Rejected). Tất cả đơn NCC → Rejected.</summary>
    [HttpPatch("{id:int}/reject")]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Reject(int id)
    {
        var o = await _db.Orders.FindAsync(id);
        if (o == null || o.IsDeleted) return NotFound();
        o.Status = "Rejected";
        o.LastStatusChangedDate = DateTime.UtcNow;
        foreach (var os in await _db.OrderSuppliers.Where(x => x.OrderId == id).ToListAsync())
            os.Status = "Rejected";
        await _db.SaveChangesAsync();
        return Ok(await GetByIdDto(id));
    }

    /// <summary>Admin đóng đơn tổng (đánh dấu Hoàn thành khi tất cả NCC đã Delivered/Rejected).</summary>
    [HttpPatch("{id:int}/confirm-total")]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ConfirmTotal(int id)
    {
        var o = await _db.Orders.FindAsync(id);
        if (o == null || o.IsDeleted) return NotFound();
        o.Status = "Completed";
        o.LastStatusChangedDate = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(await GetByIdDto(id));
    }

    /// <summary>Admin cập nhật trạng thái đơn tổng: Pending, Rejected, Accepted, Completed.</summary>
    [HttpPatch("{id:int}/status")]
    [ProducesResponseType(typeof(OrderDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> UpdateStatus(int id, [FromBody] OrderStatusDto dto)
    {
        var o = await _db.Orders.FindAsync(id);
        if (o == null || o.IsDeleted) return NotFound();
        var newStatus = (dto.Status ?? "").Trim();
        var allowed = new[] { "Pending", "Rejected", "Accepted", "Completed" };
        if (string.IsNullOrEmpty(newStatus) || !allowed.Contains(newStatus))
            return BadRequest("Status phải là một trong: " + string.Join(", ", allowed));
        o.Status = newStatus;
        o.LastStatusChangedDate = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(await GetByIdDto(id));
    }

    private async Task<OrderDto?> GetByIdDto(int id)
    {
        var o = await _db.Orders
            .AsNoTracking()
            .Include(x => x.Store)
            .Include(x => x.OrderSuppliers).ThenInclude(os => os.Supplier)
            .Include(x => x.OrderSuppliers).ThenInclude(os => os.OrderItems)
            .Include(x => x.OrderSuppliers).ThenInclude(os => os.ReceiveImages)
            .FirstOrDefaultAsync(x => x.Id == id);
        if (o == null) return null;
        return new OrderDto
        {
            Id = o.Id,
            StoreId = o.StoreId,
            StoreName = o.Store?.Name ?? "",
            Status = o.Status,
            OrderDate = o.OrderDate,
            ExpectedDeliveryDate = o.OverallExpectedDate,
            TotalItemCount = o.TotalItemCount,
            TotalAmount = o.TotalAmount,
            CreatedBy = o.CreatedBy,
            CreatedDate = o.CreatedDate,
            OrderSuppliers = o.OrderSuppliers.Select(os => new OrderSupplierDto
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
                    Price = oi.Price,
                    DiscountAmount = oi.DiscountAmount,
                    TaxPercent = oi.TaxPercent,
                    TaxAmount = oi.TaxAmount
                }).ToList(),
                ReceiveImages = (os.ReceiveImages ?? new List<ReceiveImage>()).Select(ri => new ReceiveImageDto { Id = ri.Id, Type = ri.Type, ImageUrl = ri.ImageUrl, FileName = ri.FileName }).ToList()
            }).ToList()
        };
    }
}
