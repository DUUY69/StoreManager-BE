using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AdminDashboard.Api.Data;
using AdminDashboard.Api.Models;

namespace AdminDashboard.Api.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _db;

    public UsersController(AppDbContext db)
    {
        _db = db;
    }

    private static string GenerateTempPassword()
    {
        const string chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        var rnd = new Random();
        var arr = new char[10];
        for (int i = 0; i < arr.Length; i++) arr[i] = chars[rnd.Next(chars.Length)];
        return new string(arr);
    }

    private static UserDto ToDto(User u)
    {
        return new UserDto
        {
            Id = u.Id,
            Email = u.Email,
            Name = u.Name,
            Phone = u.Phone,
            Role = u.Role,
            StoreId = u.StoreId,
            SupplierId = u.SupplierId,
            Status = u.Status
        };
    }

    [HttpGet]
    [ProducesResponseType(typeof(List<UserDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll()
    {
        var list = await _db.Users
            .AsNoTracking()
            .OrderBy(x => x.Id)
            .Select(x => new UserDto
            {
                Id = x.Id,
                Email = x.Email,
                Name = x.Name,
                Phone = x.Phone,
                Role = x.Role,
                StoreId = x.StoreId,
                SupplierId = x.SupplierId,
                Status = x.Status
            })
            .ToListAsync();
        return Ok(list);
    }

    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var u = await _db.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (u == null) return NotFound();
        return Ok(ToDto(u));
    }

    /// <summary>Tạo user. Nếu không gửi Password thì BE tự sinh và trả về TempPassword.</summary>
    [HttpPost]
    [ProducesResponseType(typeof(object), StatusCodes.Status201Created)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] CreateUserRequest dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Email))
            return BadRequest("Email không được để trống.");
        if (await _db.Users.AnyAsync(x => x.Email == dto.Email.Trim()))
            return BadRequest("Email đã tồn tại.");

        var plainPassword = string.IsNullOrWhiteSpace(dto.Password) ? GenerateTempPassword() : dto.Password.Trim();
        var tempPassword = string.IsNullOrWhiteSpace(dto.Password) ? plainPassword : null;

        var entity = new User
        {
            Email = dto.Email.Trim(),
            Name = (dto.Name ?? "").Trim(),
            Phone = string.IsNullOrWhiteSpace(dto.Phone) ? null : dto.Phone.Trim(),
            Role = string.IsNullOrWhiteSpace(dto.Role) ? "StoreUser" : dto.Role.Trim(),
            StoreId = dto.StoreId,
            SupplierId = dto.SupplierId,
            Status = string.IsNullOrWhiteSpace(dto.Status) ? "Active" : dto.Status.Trim(),
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(plainPassword),
            PasswordHashVersion = 1,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _db.Users.Add(entity);
        await _db.SaveChangesAsync();

        var userDto = ToDto(entity);
        var result = new { user = userDto, tempPassword };
        return CreatedAtAction(nameof(GetById), new { id = entity.Id }, result);
    }

    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Update(int id, [FromBody] UserDto dto)
    {
        var u = await _db.Users.FindAsync(id);
        if (u == null) return NotFound();
        if (!string.IsNullOrWhiteSpace(dto.Email) && dto.Email.Trim() != u.Email)
        {
            if (await _db.Users.AnyAsync(x => x.Id != id && x.Email == dto.Email.Trim()))
                return BadRequest("Email đã tồn tại.");
            u.Email = dto.Email.Trim();
        }
        u.Name = dto.Name ?? u.Name;
        u.Phone = dto.Phone;
        u.Role = dto.Role ?? u.Role;
        u.StoreId = dto.StoreId;
        u.SupplierId = dto.SupplierId;
        u.Status = dto.Status ?? u.Status;
        u.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(ToDto(u));
    }

    [HttpDelete("{id:int}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id)
    {
        var u = await _db.Users.FindAsync(id);
        if (u == null) return NotFound();
        _db.Users.Remove(u);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    /// <summary>Admin reset mật khẩu user – trả về mật khẩu tạm.</summary>
    [HttpPost("{id:int}/reset-password")]
    [ProducesResponseType(typeof(TempPasswordResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ResetPassword(int id)
    {
        var u = await _db.Users.FindAsync(id);
        if (u == null) return NotFound();
        var tempPassword = GenerateTempPassword();
        u.PasswordHash = BCrypt.Net.BCrypt.HashPassword(tempPassword);
        u.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        return Ok(new TempPasswordResponse { TempPassword = tempPassword });
    }
}
