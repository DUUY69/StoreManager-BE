using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminDashboard.Api.Data;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/categories")]
[Authorize]
public class CategoriesController : ControllerBase
{
    private readonly AppDbContext _db;

    public CategoriesController(AppDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    [ProducesResponseType(typeof(List<CategoryDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var list = await _db.Categories
            .AsNoTracking()
            .OrderBy(c => c.Name)
            .Select(c => new CategoryDto { Id = c.Id, Name = c.Name, Description = c.Description })
            .ToListAsync();
        return Ok(list);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(CategoryDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var c = await _db.Categories.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (c == null) return NotFound();
        return Ok(new CategoryDto { Id = c.Id, Name = c.Name, Description = c.Description });
    }

    [HttpPost]
    [ProducesResponseType(typeof(CategoryDto), StatusCodes.Status201Created)]
    public async Task<IActionResult> Create([FromBody] CategoryCreateUpdateDto dto)
    {
        var entity = new Category
        {
            Name = dto.Name?.Trim() ?? "",
            Description = dto.Description?.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _db.Categories.Add(entity);
        await _db.SaveChangesAsync();
        var created = new CategoryDto { Id = entity.Id, Name = entity.Name, Description = entity.Description };
        return CreatedAtAction(nameof(GetById), new { id = entity.Id }, created);
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(CategoryDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(int id, [FromBody] CategoryCreateUpdateDto dto)
    {
        var c = await _db.Categories.FindAsync(id);
        if (c == null) return NotFound();
        c.Name = dto.Name?.Trim() ?? c.Name;
        c.Description = dto.Description?.Trim();
        c.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(new CategoryDto { Id = c.Id, Name = c.Name, Description = c.Description });
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id)
    {
        var c = await _db.Categories.FindAsync(id);
        if (c == null) return NotFound();
        _db.Categories.Remove(c);
        await _db.SaveChangesAsync();
        return NoContent();
    }
}
