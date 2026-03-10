-- =============================================
-- Thêm cột Phone (SĐT) vào bảng Users cho trang Cài đặt / thông tin cá nhân
-- Chạy trên DB đã có schema (sau 01_Schema.sql, 02_SeedData.sql)
-- =============================================

USE AdminDashboard;
GO
SET NOCOUNT ON;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns c
    INNER JOIN sys.tables t ON c.object_id = t.object_id
    WHERE t.name = N'Users' AND c.name = N'Phone'
)
BEGIN
    ALTER TABLE dbo.Users ADD Phone NVARCHAR(50) NULL;
    PRINT N'Users.Phone added.';
END
ELSE
    PRINT N'Users.Phone already exists.';
GO

-- Cập nhật số điện thoại mẫu cho user seed (tùy chọn)
UPDATE dbo.Users SET Phone = N'0900000001' WHERE Id = 1 AND Email = N'admin@cafe.vn';
UPDATE dbo.Users SET Phone = N'0900000002' WHERE Id = 2 AND Email = N'q1@cafe.vn';
UPDATE dbo.Users SET Phone = N'0900000003' WHERE Id = 3 AND Email = N'q7@cafe.vn';
UPDATE dbo.Users SET Phone = N'0900000004' WHERE Id = 4 AND Email = N'bt@cafe.vn';
UPDATE dbo.Users SET Phone = N'0911000001' WHERE Id = 5 AND Email = N'ncc_caphe@supplier.vn';
UPDATE dbo.Users SET Phone = N'0911000002' WHERE Id = 6 AND Email = N'ncc_sua@supplier.vn';
UPDATE dbo.Users SET Phone = N'0911000003' WHERE Id = 7 AND Email = N'ncc_syrup@supplier.vn';
UPDATE dbo.Users SET Phone = N'0911000004' WHERE Id = 8 AND Email = N'ncc_banh@supplier.vn';
UPDATE dbo.Users SET Phone = N'0911000005' WHERE Id = 9 AND Email = N'ncc_vattu@supplier.vn';
PRINT N'User phones updated (sample).';
GO
