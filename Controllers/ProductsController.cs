using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminDashboard.Api.Data;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/products")]
[Authorize]
public class ProductsController : ControllerBase
{
    private readonly AppDbContext _db;

    public ProductsController(AppDbContext db)
    {
        _db = db;
    }

    /// <summary>Danh sách sản phẩm. Query: search, supplierId, categoryId, status.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(List<ProductDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll([FromQuery] string? search, [FromQuery] int? supplierId, [FromQuery] int? categoryId, [FromQuery] string? status)
    {
        var query = _db.Products.AsNoTracking();
        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim().ToLower();
            query = query.Where(p =>
                (p.Code != null && p.Code.ToLower().Contains(term)) ||
                (p.Name != null && p.Name.ToLower().Contains(term)));
        }
        if (supplierId.HasValue)
            query = query.Where(p => p.SupplierId == supplierId.Value);
        if (categoryId.HasValue)
            query = query.Where(p => p.CategoryId == categoryId.Value);
        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(p => p.Status == status.Trim());

        var list = await query
            .OrderBy(p => p.Code)
            .Select(p => new ProductDto
            {
                Id = p.Id,
                Code = p.Code,
                Name = p.Name,
                SupplierId = p.SupplierId,
                CategoryId = p.CategoryId,
                Unit = p.Unit,
                Price = p.Price,
                Status = p.Status
            })
            .ToListAsync();
        return Ok(list);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var p = await _db.Products.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (p == null) return NotFound();
        return Ok(new ProductDto { Id = p.Id, Code = p.Code, Name = p.Name, SupplierId = p.SupplierId, CategoryId = p.CategoryId, Unit = p.Unit, Price = p.Price, Status = p.Status });
    }

    [HttpPost]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create([FromBody] ProductCreateUpdateDto dto)
    {
        var entity = new Product
        {
            Code = dto.Code?.Trim() ?? "",
            Name = dto.Name?.Trim() ?? "",
            SupplierId = dto.SupplierId,
            CategoryId = dto.CategoryId,
            Unit = string.IsNullOrWhiteSpace(dto.Unit) ? "cái" : dto.Unit.Trim(),
            Price = dto.Price,
            Status = string.IsNullOrWhiteSpace(dto.Status) ? "Active" : dto.Status.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _db.Products.Add(entity);
        await _db.SaveChangesAsync();
        var created = new ProductDto { Id = entity.Id, Code = entity.Code, Name = entity.Name, SupplierId = entity.SupplierId, CategoryId = entity.CategoryId, Unit = entity.Unit, Price = entity.Price, Status = entity.Status };
        return CreatedAtAction(nameof(GetById), new { id = entity.Id }, created);
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(int id, [FromBody] ProductCreateUpdateDto dto)
    {
        var p = await _db.Products.FindAsync(id);
        if (p == null) return NotFound();
        p.Code = dto.Code?.Trim() ?? p.Code;
        p.Name = dto.Name?.Trim() ?? p.Name;
        p.SupplierId = dto.SupplierId;
        p.CategoryId = dto.CategoryId;
        if (!string.IsNullOrWhiteSpace(dto.Unit)) p.Unit = dto.Unit.Trim();
        p.Price = dto.Price;
        if (!string.IsNullOrWhiteSpace(dto.Status)) p.Status = dto.Status.Trim();
        p.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(new ProductDto { Id = p.Id, Code = p.Code, Name = p.Name, SupplierId = p.SupplierId, CategoryId = p.CategoryId, Unit = p.Unit, Price = p.Price, Status = p.Status });
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id)
    {
        var p = await _db.Products.FindAsync(id);
        if (p == null) return NotFound();
        _db.Products.Remove(p);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
