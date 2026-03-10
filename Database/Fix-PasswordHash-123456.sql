-- Chạy script này nếu đăng nhập bị 401 (hash trong DB sai/lỗi).
-- Cập nhật PasswordHash BCrypt đúng cho mật khẩu "123456" (cùng hash trong 02_SeedData.sql).
-- Chạy trên đúng database mà API đang dùng (xem ConnectionString trong appsettings.json).

UPDATE dbo.Users
SET PasswordHash = N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy',
    UpdatedAt = GETUTCDATE()
WHERE Email IN (N'admin@cafe.vn', N'q1@cafe.vn', N'q7@cafe.vn', N'bt@cafe.vn', N'ncc_caphe@supplier.vn', N'ncc_sua@supplier.vn', N'ncc_syrup@supplier.vn', N'ncc_banh@supplier.vn', N'ncc_vattu@supplier.vn');

PRINT N'Đã cập nhật PasswordHash cho các user (mật khẩu: 123456). Thử đăng nhập lại.';
