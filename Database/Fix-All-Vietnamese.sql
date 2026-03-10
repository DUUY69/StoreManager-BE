-- =============================================
-- Sửa dữ liệu tiếng Việt bị lỗi (mojibake) cho TẤT CẢ các bảng
-- Nguyên nhân: script seed chạy với file encoding sai (ANSI thay vì UTF-8)
-- Cách chạy: Lưu file này dạng UTF-8 (có BOM) rồi mở và Execute trong SSMS
-- =============================================

USE AdminDashboard;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO

-- =============================================
-- 1. Categories
-- =============================================
SET IDENTITY_INSERT dbo.Categories ON;
UPDATE dbo.Categories SET Name = N'Cà phê', Description = N'Cà phê hạt, cà phê bột, espresso...' WHERE Id = 1;
UPDATE dbo.Categories SET Name = N'Trà & Đồ uống', Description = N'Trà túi lọc, trà sữa, nước ép...' WHERE Id = 2;
UPDATE dbo.Categories SET Name = N'Sữa & Kem', Description = N'Sữa tươi, sữa đặc, whipping cream...' WHERE Id = 3;
UPDATE dbo.Categories SET Name = N'Syrup & Topping', Description = N'Syrup caramel, chocolate, topping...' WHERE Id = 4;
UPDATE dbo.Categories SET Name = N'Bánh & Snack', Description = N'Bánh ngọt, bánh mì, snack...' WHERE Id = 5;
UPDATE dbo.Categories SET Name = N'Vật tư cafe', Description = N'Ly, ống hút, nắp, tăm...' WHERE Id = 6;
SET IDENTITY_INSERT dbo.Categories OFF;
PRINT N'Categories: Đã sửa xong.';

-- =============================================
-- 2. Suppliers
-- =============================================
SET IDENTITY_INSERT dbo.Suppliers ON;
UPDATE dbo.Suppliers SET Code = N'NCC01', Name = N'Công ty Cà phê Trung Nguyên', Contact = N'0901234567', Email = N'trungnguyen@supplier.vn', Address = N'Q.1, TP.HCM', Status = N'Active' WHERE Id = 1;
UPDATE dbo.Suppliers SET Code = N'NCC02', Name = N'Công ty Sữa & Đồ uống Vinamilk', Contact = N'0912345678', Email = N'vinamilk@supplier.vn', Address = N'Q.7, TP.HCM', Status = N'Active' WHERE Id = 2;
UPDATE dbo.Suppliers SET Code = N'NCC03', Name = N'NCC Syrup & Topping Monin', Contact = N'0923456789', Email = N'monin@supplier.vn', Address = N'Bình Thạnh, TP.HCM', Status = N'Active' WHERE Id = 3;
UPDATE dbo.Suppliers SET Code = N'NCC04', Name = N'Công ty Bánh & Snack Kinh Đô', Contact = N'0934567890', Email = N'kinhdo@supplier.vn', Address = N'Q.3, TP.HCM', Status = N'Active' WHERE Id = 4;
UPDATE dbo.Suppliers SET Code = N'NCC05', Name = N'Công ty Vật tư F&B Toàn Thắng', Contact = N'0945678901', Email = N'toanthang@supplier.vn', Address = N'Q.12, TP.HCM', Status = N'Active' WHERE Id = 5;
SET IDENTITY_INSERT dbo.Suppliers OFF;
PRINT N'Suppliers: Đã sửa xong.';

-- =============================================
-- 3. Stores
-- =============================================
SET IDENTITY_INSERT dbo.Stores ON;
UPDATE dbo.Stores SET Code = N'CF01', Name = N'Cafe Sài Gòn - Quận 1', Address = N'123 Nguyễn Huệ, Q.1, TP.HCM', Phone = N'0281234567', Status = N'Active' WHERE Id = 1;
UPDATE dbo.Stores SET Code = N'CF02', Name = N'Cafe Sài Gòn - Quận 7', Address = N'456 Nguyễn Lương Bằng, Q.7, TP.HCM', Phone = N'0282345678', Status = N'Active' WHERE Id = 2;
UPDATE dbo.Stores SET Code = N'CF03', Name = N'Cafe Sài Gòn - Bình Thạnh', Address = N'789 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM', Phone = N'0283456789', Status = N'Active' WHERE Id = 3;
SET IDENTITY_INSERT dbo.Stores OFF;
PRINT N'Stores: Đã sửa xong.';

-- =============================================
-- 4. Users
-- =============================================
SET IDENTITY_INSERT dbo.Users ON;
UPDATE dbo.Users SET Email = N'admin@cafe.vn', Name = N'Admin Cafe', Phone = N'0900000001', Role = N'Admin', Status = N'Active' WHERE Id = 1;
UPDATE dbo.Users SET Email = N'q1@cafe.vn', Name = N'Nguyễn Văn An', Phone = N'0900000002', Role = N'StoreUser', Status = N'Active' WHERE Id = 2;
UPDATE dbo.Users SET Email = N'q7@cafe.vn', Name = N'Trần Thị Bình', Phone = N'0900000003', Role = N'StoreUser', Status = N'Active' WHERE Id = 3;
UPDATE dbo.Users SET Email = N'bt@cafe.vn', Name = N'Lê Thị Hương', Phone = N'0900000004', Role = N'StoreUser', Status = N'Active' WHERE Id = 4;
UPDATE dbo.Users SET Email = N'ncc_caphe@supplier.vn', Name = N'Lê Văn Cường', Phone = N'0911000001', Role = N'SupplierUser', Status = N'Active' WHERE Id = 5;
UPDATE dbo.Users SET Email = N'ncc_sua@supplier.vn', Name = N'Phạm Thị Dung', Phone = N'0911000002', Role = N'SupplierUser', Status = N'Active' WHERE Id = 6;
UPDATE dbo.Users SET Email = N'ncc_syrup@supplier.vn', Name = N'Hoàng Văn Em', Phone = N'0911000003', Role = N'SupplierUser', Status = N'Active' WHERE Id = 7;
UPDATE dbo.Users SET Email = N'ncc_banh@supplier.vn', Name = N'Võ Minh Tuấn', Phone = N'0911000004', Role = N'SupplierUser', Status = N'Active' WHERE Id = 8;
UPDATE dbo.Users SET Email = N'ncc_vattu@supplier.vn', Name = N'Đặng Thị Lan', Phone = N'0911000005', Role = N'SupplierUser', Status = N'Active' WHERE Id = 9;
UPDATE dbo.Users SET Email = N'ncc_caphe2@supplier.vn', Name = N'Nguyễn Thị Hoa', Phone = N'0911000011', Role = N'SupplierUser', Status = N'Active' WHERE Id = 10;
UPDATE dbo.Users SET Email = N'ncc_sua2@supplier.vn', Name = N'Trần Văn Đức', Phone = N'0911000012', Role = N'SupplierUser', Status = N'Active' WHERE Id = 11;
UPDATE dbo.Users SET Email = N'ncc_syrup2@supplier.vn', Name = N'Lê Thị Mai', Phone = N'0911000013', Role = N'SupplierUser', Status = N'Active' WHERE Id = 12;
UPDATE dbo.Users SET Email = N'ncc_banh2@supplier.vn', Name = N'Phạm Văn Hùng', Phone = N'0911000014', Role = N'SupplierUser', Status = N'Active' WHERE Id = 13;
UPDATE dbo.Users SET Email = N'ncc_vattu2@supplier.vn', Name = N'Hoàng Thị Nga', Phone = N'0911000015', Role = N'SupplierUser', Status = N'Active' WHERE Id = 14;
SET IDENTITY_INSERT dbo.Users OFF;
PRINT N'Users: Đã sửa xong.';

-- =============================================
-- 5. Products
-- =============================================
SET IDENTITY_INSERT dbo.Products ON;
UPDATE dbo.Products SET Code = N'CF001', Name = N'Cà phê Arabica rang xay 1kg', Unit = N'túi', Status = N'Active' WHERE Id = 1;
UPDATE dbo.Products SET Code = N'CF002', Name = N'Cà phê Robusta Premium 1kg', Unit = N'túi', Status = N'Active' WHERE Id = 2;
UPDATE dbo.Products SET Code = N'CF003', Name = N'Espresso blend 500g', Unit = N'hộp', Status = N'Active' WHERE Id = 3;
UPDATE dbo.Products SET Code = N'TR001', Name = N'Trà Earl Grey túi lọc 100 gói', Unit = N'hộp', Status = N'Active' WHERE Id = 4;
UPDATE dbo.Products SET Code = N'SU001', Name = N'Sữa tươi có đường 1L', Unit = N'thùng', Status = N'Active' WHERE Id = 5;
UPDATE dbo.Products SET Code = N'SU002', Name = N'Sữa đặc Ông Thọ 380g', Unit = N'thùng', Status = N'Active' WHERE Id = 6;
UPDATE dbo.Products SET Code = N'SU003', Name = N'Kem whipping 1L', Unit = N'hộp', Status = N'Active' WHERE Id = 7;
UPDATE dbo.Products SET Code = N'SY001', Name = N'Syrup Caramel Monin 700ml', Unit = N'chai', Status = N'Active' WHERE Id = 8;
UPDATE dbo.Products SET Code = N'SY002', Name = N'Syrup Chocolate Monin 700ml', Unit = N'chai', Status = N'Active' WHERE Id = 9;
UPDATE dbo.Products SET Code = N'SY003', Name = N'Sốt caramel chai 1L', Unit = N'chai', Status = N'Active' WHERE Id = 10;
UPDATE dbo.Products SET Code = N'BH001', Name = N'Bánh croissant', Unit = N'thùng', Status = N'Active' WHERE Id = 11;
UPDATE dbo.Products SET Code = N'BH002', Name = N'Bánh muffin chocolate', Unit = N'thùng', Status = N'Active' WHERE Id = 12;
UPDATE dbo.Products SET Code = N'VT001', Name = N'Ly giấy takeaway 12oz 100c', Unit = N'bịch', Status = N'Active' WHERE Id = 13;
UPDATE dbo.Products SET Code = N'VT002', Name = N'Ống hút giấy 500 ống', Unit = N'bịch', Status = N'Active' WHERE Id = 14;
UPDATE dbo.Products SET Code = N'CF004', Name = N'Cà phê Moka Đắk Lắk 500g', Unit = N'túi', Status = N'Active' WHERE Id = 15;
UPDATE dbo.Products SET Code = N'CF005', Name = N'Cà phê hòa tan 3in1 gói 25 gói', Unit = N'thùng', Status = N'Active' WHERE Id = 16;
UPDATE dbo.Products SET Code = N'TR002', Name = N'Trà đen Ceylon 100 gói', Unit = N'hộp', Status = N'Active' WHERE Id = 17;
UPDATE dbo.Products SET Code = N'TR003', Name = N'Trà xanh matcha 200g', Unit = N'hộp', Status = N'Active' WHERE Id = 18;
UPDATE dbo.Products SET Code = N'SU004', Name = N'Sữa tươi không đường 1L', Unit = N'thùng', Status = N'Active' WHERE Id = 19;
UPDATE dbo.Products SET Code = N'SU005', Name = N'Kem béo nguyên chất 35% 1L', Unit = N'hộp', Status = N'Active' WHERE Id = 20;
UPDATE dbo.Products SET Code = N'SY004', Name = N'Syrup Vanilla Monin 700ml', Unit = N'chai', Status = N'Active' WHERE Id = 21;
UPDATE dbo.Products SET Code = N'SY005', Name = N'Syrup Hazelnut 700ml', Unit = N'chai', Status = N'Active' WHERE Id = 22;
UPDATE dbo.Products SET Code = N'BH003', Name = N'Bánh bông lan cuộn', Unit = N'thùng', Status = N'Active' WHERE Id = 23;
UPDATE dbo.Products SET Code = N'BH004', Name = N'Bánh cookie socola', Unit = N'gói', Status = N'Active' WHERE Id = 24;
UPDATE dbo.Products SET Code = N'VT003', Name = N'Ly nhựa PP 16oz 50c', Unit = N'bịch', Status = N'Active' WHERE Id = 25;
UPDATE dbo.Products SET Code = N'VT004', Name = N'Nắp ly nhựa 16oz 100c', Unit = N'bịch', Status = N'Active' WHERE Id = 26;
UPDATE dbo.Products SET Code = N'VT005', Name = N'Túi giấy kraft 100 túi', Unit = N'cuộn', Status = N'Active' WHERE Id = 27;
UPDATE dbo.Products SET Code = N'CF006', Name = N'Decaf espresso 500g', Unit = N'hộp', Status = N'Active' WHERE Id = 28;
SET IDENTITY_INSERT dbo.Products OFF;
PRINT N'Products: Đã sửa xong.';

-- =============================================
-- 6. Orders (Status có thể bị méo)
-- =============================================
UPDATE dbo.Orders SET Status = N'Pending' WHERE Id = 1;
UPDATE dbo.Orders SET Status = N'Accepted' WHERE Id = 2;
UPDATE dbo.Orders SET Status = N'Completed' WHERE Id = 3;
UPDATE dbo.Orders SET Status = N'Pending' WHERE Id = 4;
UPDATE dbo.Orders SET Status = N'Rejected' WHERE Id = 5;
PRINT N'Orders: Đã sửa xong (Pending|Rejected|Accepted|Completed).';

-- =============================================
-- 7. OrderSuppliers
-- =============================================
UPDATE dbo.OrderSuppliers SET Status = N'Pending', PaymentStatus = N'Unpaid' WHERE Id = 1;
UPDATE dbo.OrderSuppliers SET Status = N'Pending', PaymentStatus = N'Unpaid' WHERE Id = 2;
UPDATE dbo.OrderSuppliers SET Status = N'Accepted', PaymentStatus = N'Unpaid' WHERE Id = 3;
UPDATE dbo.OrderSuppliers SET Status = N'Delivering', PaymentStatus = N'Unpaid' WHERE Id = 4;
UPDATE dbo.OrderSuppliers SET Status = N'Delivered', PaymentStatus = N'Unpaid' WHERE Id = 5;
UPDATE dbo.OrderSuppliers SET Status = N'Delivered', PaymentStatus = N'Unpaid' WHERE Id = 6;
UPDATE dbo.OrderSuppliers SET Status = N'Delivered', PaymentStatus = N'Unpaid' WHERE Id = 7;
UPDATE dbo.OrderSuppliers SET Status = N'Rejected', PaymentStatus = N'Unpaid' WHERE Id = 8;
PRINT N'OrderSuppliers: Đã sửa xong.';

-- =============================================
-- 8. OrderItems (ProductName, Unit)
-- =============================================
UPDATE dbo.OrderItems SET ProductName = N'Cà phê Arabica rang xay 1kg', Unit = N'túi' WHERE Id = 1;
UPDATE dbo.OrderItems SET ProductName = N'Cà phê Robusta Premium 1kg', Unit = N'túi' WHERE Id = 2;
UPDATE dbo.OrderItems SET ProductName = N'Sữa tươi có đường 1L', Unit = N'thùng' WHERE Id = 3;
UPDATE dbo.OrderItems SET ProductName = N'Sữa đặc Ông Thọ 380g', Unit = N'thùng' WHERE Id = 4;
UPDATE dbo.OrderItems SET ProductName = N'Cà phê Arabica rang xay 1kg', Unit = N'túi' WHERE Id = 5;
UPDATE dbo.OrderItems SET ProductName = N'Espresso blend 500g', Unit = N'hộp' WHERE Id = 6;
UPDATE dbo.OrderItems SET ProductName = N'Syrup Caramel Monin 700ml', Unit = N'chai' WHERE Id = 7;
UPDATE dbo.OrderItems SET ProductName = N'Cà phê Arabica rang xay 1kg', Unit = N'túi' WHERE Id = 8;
UPDATE dbo.OrderItems SET ProductName = N'Cà phê Robusta Premium 1kg', Unit = N'túi' WHERE Id = 9;
UPDATE dbo.OrderItems SET ProductName = N'Sữa tươi có đường 1L', Unit = N'thùng' WHERE Id = 10;
UPDATE dbo.OrderItems SET ProductName = N'Kem whipping 1L', Unit = N'hộp' WHERE Id = 11;
UPDATE dbo.OrderItems SET ProductName = N'Syrup Caramel Monin 700ml', Unit = N'chai' WHERE Id = 12;
UPDATE dbo.OrderItems SET ProductName = N'Syrup Chocolate Monin 700ml', Unit = N'chai' WHERE Id = 13;
UPDATE dbo.OrderItems SET ProductName = N'Cà phê Arabica rang xay 1kg', Unit = N'túi' WHERE Id = 14;
PRINT N'OrderItems: Đã sửa xong.';

-- =============================================
-- 9. ReceiveImages
-- =============================================
UPDATE dbo.ReceiveImages SET Type = N'received', FileName = N'anh-hang-nhan.jpg', Description = N'Ảnh hàng nhận từ NCC Cà phê' WHERE Id = 1;
UPDATE dbo.ReceiveImages SET Type = N'invoice', FileName = N'hoa-don-ky.jpg', Description = N'Hóa đơn đã ký' WHERE Id = 2;
PRINT N'ReceiveImages: Đã sửa xong.';

-- =============================================
-- 10. StockTransactions (Note)
-- =============================================
UPDATE dbo.StockTransactions SET TransactionType = N'In', Note = N'Nhập kho từ đơn #3 - NCC Cà phê' WHERE Id = 1;
UPDATE dbo.StockTransactions SET TransactionType = N'In', Note = N'Nhập kho từ đơn #3' WHERE Id = 2;
UPDATE dbo.StockTransactions SET TransactionType = N'In', Note = N'Nhập kho từ đơn #3 - NCC Sữa' WHERE Id = 3;
UPDATE dbo.StockTransactions SET TransactionType = N'In', Note = N'Nhập kho từ đơn #3' WHERE Id = 4;
UPDATE dbo.StockTransactions SET TransactionType = N'In', Note = N'Nhập kho từ đơn #3 - NCC Syrup' WHERE Id = 5;
UPDATE dbo.StockTransactions SET TransactionType = N'In', Note = N'Nhập kho từ đơn #3' WHERE Id = 6;
PRINT N'StockTransactions: Đã sửa xong.';

PRINT N'';
PRINT N'=== Hoàn tất: Đã sửa tiếng Việt cho tất cả các bảng. ===';
GO
