namespace AdminDashboard.Api.Models;

public class UserDto
{
    public int Id { get; set; }
    public string Email { get; set; } = "";
    public string Name { get; set; } = "";
    /// <summary>Số điện thoại (cập nhật từ trang Cài đặt).</summary>
    public string? Phone { get; set; }
    public string Role { get; set; } = "";
    public int? StoreId { get; set; }
    public int? SupplierId { get; set; }
    public string Status { get; set; } = "Active";
}

public class LoginRequest
{
    public string Email { get; set; } = "";
    public string Password { get; set; } = "";
}

public class LoginResponse
{
    public UserDto User { get; set; } = null!;
    public string Token { get; set; } = "";
}

/// <summary>Cập nhật thông tin cá nhân (tên, email, SĐT).</summary>
public class UpdateProfileRequest
{
    public string Name { get; set; } = "";
    public string Email { get; set; } = "";
    public string? Phone { get; set; }
}

/// <summary>Đổi mật khẩu của chính mình.</summary>
public class ChangePasswordRequest
{
    public string CurrentPassword { get; set; } = "";
    public string NewPassword { get; set; } = "";
}

/// <summary>Tạo user (Admin) – mật khẩu tùy chọn, nếu không gửi thì BE tự sinh.</summary>
public class CreateUserRequest
{
    public string Email { get; set; } = "";
    public string Name { get; set; } = "";
    public string? Phone { get; set; }
    public string Role { get; set; } = "";
    public int? StoreId { get; set; }
    public int? SupplierId { get; set; }
    public string Status { get; set; } = "Active";
    /// <summary>Mật khẩu (tùy chọn). Nếu null/empty, backend tự sinh và trả về TempPassword.</summary>
    public string? Password { get; set; }
}

/// <summary>Kết quả tạo user hoặc reset mật khẩu – trả mật khẩu tạm cho Admin.</summary>
public class TempPasswordResponse
{
    public string TempPassword { get; set; } = "";
}
