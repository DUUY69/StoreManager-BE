using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminDashboard.Api.Data;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/stores")]
[Authorize]
public class StoresController : ControllerBase
{
    private readonly AppDbContext _db;

    public StoresController(AppDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    [ProducesResponseType(typeof(List<StoreDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var list = await _db.Stores
            .AsNoTracking()
            .OrderBy(s => s.Code)
            .Select(s => new StoreDto { Id = s.Id, Code = s.Code, Name = s.Name, Address = s.Address, Phone = s.Phone, Status = s.Status })
            .ToListAsync();
        return Ok(list);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(StoreDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var s = await _db.Stores.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (s == null) return NotFound();
        return Ok(new StoreDto { Id = s.Id, Code = s.Code, Name = s.Name, Address = s.Address, Phone = s.Phone, Status = s.Status });
    }

    [HttpPost]
    [ProducesResponseType(typeof(StoreDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create([FromBody] StoreCreateUpdateDto dto)
    {
        var entity = new Store
        {
            Code = dto.Code?.Trim() ?? "",
            Name = dto.Name?.Trim() ?? "",
            Address = dto.Address?.Trim(),
            Phone = dto.Phone?.Trim(),
            Status = string.IsNullOrWhiteSpace(dto.Status) ? "Active" : dto.Status.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _db.Stores.Add(entity);
        await _db.SaveChangesAsync();
        var created = new StoreDto { Id = entity.Id, Code = entity.Code, Name = entity.Name, Address = entity.Address, Phone = entity.Phone, Status = entity.Status };
        return CreatedAtAction(nameof(GetById), new { id = entity.Id }, created);
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(StoreDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(int id, [FromBody] StoreCreateUpdateDto dto)
    {
        var s = await _db.Stores.FindAsync(id);
        if (s == null) return NotFound();
        s.Code = dto.Code?.Trim() ?? s.Code;
        s.Name = dto.Name?.Trim() ?? s.Name;
        s.Address = dto.Address?.Trim();
        s.Phone = dto.Phone?.Trim();
        if (!string.IsNullOrWhiteSpace(dto.Status)) s.Status = dto.Status.Trim();
        s.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(new StoreDto { Id = s.Id, Code = s.Code, Name = s.Name, Address = s.Address, Phone = s.Phone, Status = s.Status });
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id)
    {
        var s = await _db.Stores.FindAsync(id);
        if (s == null) return NotFound();
        _db.Stores.Remove(s);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
