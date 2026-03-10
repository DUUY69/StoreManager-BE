using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminDashboard.Api.Data;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/suppliers")]
[Authorize]
public class SuppliersController : ControllerBase
{
    private readonly AppDbContext _db;

    public SuppliersController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>Danh sách nhà cung cấp. Query: search, status (Active|Inactive).</summary>
    [HttpGet]
    [ProducesResponseType(typeof(List<SupplierDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll([FromQuery] string? search, [FromQuery] string? status)
    {
        var query = _db.Suppliers.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = query.Where(s =>
                (s.Code != null && s.Code.ToLower().Contains(term)) ||
                (s.Name != null && s.Name.ToLower().Contains(term)) ||
                (s.Email != null && s.Email.ToLower().Contains(term)));
        }
        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(s => s.Status == status.Trim());

        var list = await query
            .OrderBy(s => s.Code)
            .Select(s => new SupplierDto
            {
                Id = s.Id,
                Code = s.Code,
                Name = s.Name,
                Contact = s.Contact,
                Email = s.Email,
                Address = s.Address,
                Status = s.Status
            })
            .ToListAsync();
        return Ok(list);
    }

    /// <summary>Lấy một NCC theo id.</summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(SupplierDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var s = await _db.Suppliers.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (s == null) return NotFound();
        return Ok(new SupplierDto { Id = s.Id, Code = s.Code, Name = s.Name, Contact = s.Contact, Email = s.Email, Address = s.Address, Status = s.Status });
    }

    /// <summary>Tạo nhà cung cấp mới.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(SupplierDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create([FromBody] SupplierCreateUpdateDto dto)
    {
        var entity = new Supplier
        {
            Code = dto.Code?.Trim() ?? "",
            Name = dto.Name?.Trim() ?? "",
            Contact = dto.Contact?.Trim(),
            Email = dto.Email?.Trim(),
            Address = dto.Address?.Trim(),
            Status = string.IsNullOrWhiteSpace(dto.Status) ? "Active" : dto.Status.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _db.Suppliers.Add(entity);
        await _db.SaveChangesAsync();
        var created = new SupplierDto { Id = entity.Id, Code = entity.Code, Name = entity.Name, Contact = entity.Contact, Email = entity.Email, Address = entity.Address, Status = entity.Status };
        return CreatedAtAction(nameof(GetById), new { id = entity.Id }, created);
    }

    /// <summary>Cập nhật NCC.</summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(SupplierDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(int id, [FromBody] SupplierCreateUpdateDto dto)
    {
        var s = await _db.Suppliers.FindAsync(id);
        if (s == null) return NotFound();
        s.Code = dto.Code?.Trim() ?? s.Code;
        s.Name = dto.Name?.Trim() ?? s.Name;
        s.Contact = dto.Contact?.Trim();
        s.Email = dto.Email?.Trim();
        s.Address = dto.Address?.Trim();
        if (!string.IsNullOrWhiteSpace(dto.Status)) s.Status = dto.Status.Trim();
        s.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(new SupplierDto { Id = s.Id, Code = s.Code, Name = s.Name, Contact = s.Contact, Email = s.Email, Address = s.Address, Status = s.Status });
    }

    /// <summary>Xóa NCC.</summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id)
    {
        var s = await _db.Suppliers.FindAsync(id);
        if (s == null) return NotFound();
        _db.Suppliers.Remove(s);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
