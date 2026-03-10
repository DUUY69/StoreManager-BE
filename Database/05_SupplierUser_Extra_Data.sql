-- =============================================
-- Bổ sung thêm SupplierUser (user phụ cho mỗi NCC) - chạy trên DB đã có 9 user
-- Mật khẩu demo: 123456 (cùng BCrypt hash)
-- =============================================

USE AdminDashboard;
GO
SET NOCOUNT ON;
GO

-- Insert 5 user phụ (Id 10-14) nếu chưa tồn tại
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Id = 10)
BEGIN
    SET IDENTITY_INSERT dbo.Users ON;
    INSERT INTO dbo.Users (Id, Email, PasswordHash, PasswordSalt, PasswordHashVersion, Name, Phone, Role, StoreId, SupplierId, Status) VALUES
    (10, N'ncc_caphe2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Nguyễn Thị Hoa', N'0911000011', N'SupplierUser', NULL, 1, N'Active'),
    (11, N'ncc_sua2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Trần Văn Đức', N'0911000012', N'SupplierUser', NULL, 2, N'Active'),
    (12, N'ncc_syrup2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Lê Thị Mai', N'0911000013', N'SupplierUser', NULL, 3, N'Active'),
    (13, N'ncc_banh2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Phạm Văn Hùng', N'0911000014', N'SupplierUser', NULL, 4, N'Active'),
    (14, N'ncc_vattu2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Hoàng Thị Nga', N'0911000015', N'SupplierUser', NULL, 5, N'Active');
    SET IDENTITY_INSERT dbo.Users OFF;
    PRINT N'SupplierUser extra: 5 rows inserted (Id 10-14). Password: 123456';
END
ELSE
    PRINT N'SupplierUser extra: Id 10-14 already exist.';
GO
