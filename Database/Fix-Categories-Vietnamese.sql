z`-- =============================================
-- Sửa dữ liệu tiếng Việt bị lỗi (mojibake) trong bảng Categories
-- Nguyên nhân: script seed chạy với file encoding sai (ANSI thay vì UTF-8)
-- Cách chạy: Lưu file này dạng UTF-8 (có BOM) rồi mở và Execute trong SSMS
-- =============================================

USE AdminDashboard;
GO

SET IDENTITY_INSERT dbo.Categories ON;

-- Cập nhật lại đúng nội dung tiếng Việt (dùng N'...' và lưu file UTF-8)
UPDATE dbo.Categories SET Name = N'Cà phê', Description = N'Cà phê hạt, cà phê bột, espresso...' WHERE Id = 1;
UPDATE dbo.Categories SET Name = N'Trà & Đồ uống', Description = N'Trà túi lọc, trà sữa, nước ép...' WHERE Id = 2;
UPDATE dbo.Categories SET Name = N'Sữa & Kem', Description = N'Sữa tươi, sữa đặc, whipping cream...' WHERE Id = 3;
UPDATE dbo.Categories SET Name = N'Syrup & Topping', Description = N'Syrup caramel, chocolate, topping...' WHERE Id = 4;
UPDATE dbo.Categories SET Name = N'Bánh & Snack', Description = N'Bánh ngọt, bánh mì, snack...' WHERE Id = 5;
UPDATE dbo.Categories SET Name = N'Vật tư cafe', Description = N'Ly, ống hút, nắp, tăm...' WHERE Id = 6;

SET IDENTITY_INSERT dbo.Categories OFF;

PRINT N'Categories: Đã sửa xong 6 dòng tiếng Việt.';
GO
