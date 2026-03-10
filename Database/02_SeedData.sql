-- =============================================
-- Admin Dashboard - Dữ liệu mẫu (Seed Data)
-- Chạy sau 01_Schema.sql
-- Mật khẩu demo: dùng BCrypt hash của "123456" hoặc do Backend set khi đăng ký
--
-- QUAN TRỌNG - Tiếng Việt: Lưu file này dạng UTF-8 (có BOM) trước khi chạy
-- trong SSMS, nếu không dữ liệu sẽ bị lỗi hiển thị (mojibake).
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
IF NOT EXISTS (SELECT 1 FROM dbo.Categories)
BEGIN
    SET IDENTITY_INSERT dbo.Categories ON;
    INSERT INTO dbo.Categories (Id, Name, Description) VALUES
    (1, N'Cà phê', N'Cà phê hạt, cà phê bột, espresso...'),
    (2, N'Trà & Đồ uống', N'Trà túi lọc, trà sữa, nước ép...'),
    (3, N'Sữa & Kem', N'Sữa tươi, sữa đặc, whipping cream...'),
    (4, N'Syrup & Topping', N'Syrup caramel, chocolate, topping...'),
    (5, N'Bánh & Snack', N'Bánh ngọt, bánh mì, snack...'),
    (6, N'Vật tư cafe', N'Ly, ống hút, nắp, tăm...');
    SET IDENTITY_INSERT dbo.Categories OFF;
    PRINT N'Categories: 6 rows inserted.';
END
GO

-- =============================================
-- 2. Suppliers
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.Suppliers)
BEGIN
    SET IDENTITY_INSERT dbo.Suppliers ON;
    INSERT INTO dbo.Suppliers (Id, Code, Name, Contact, Email, Address, Status) VALUES
    (1, N'NCC01', N'Công ty Cà phê Trung Nguyên', N'0901234567', N'trungnguyen@supplier.vn', N'Q.1, TP.HCM', N'Active'),
    (2, N'NCC02', N'Công ty Sữa & Đồ uống Vinamilk', N'0912345678', N'vinamilk@supplier.vn', N'Q.7, TP.HCM', N'Active'),
    (3, N'NCC03', N'NCC Syrup & Topping Monin', N'0923456789', N'monin@supplier.vn', N'Bình Thạnh, TP.HCM', N'Active'),
    (4, N'NCC04', N'Công ty Bánh & Snack Kinh Đô', N'0934567890', N'kinhdo@supplier.vn', N'Q.3, TP.HCM', N'Active'),
    (5, N'NCC05', N'Công ty Vật tư F&B Toàn Thắng', N'0945678901', N'toanthang@supplier.vn', N'Q.12, TP.HCM', N'Active');
    SET IDENTITY_INSERT dbo.Suppliers OFF;
    PRINT N'Suppliers: 5 rows inserted.';
END
GO

-- =============================================
-- 3. Stores
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.Stores)
BEGIN
    SET IDENTITY_INSERT dbo.Stores ON;
    INSERT INTO dbo.Stores (Id, Code, Name, Address, Phone, Status) VALUES
    (1, N'CF01', N'Cafe Sài Gòn - Quận 1', N'123 Nguyễn Huệ, Q.1, TP.HCM', N'0281234567', N'Active'),
    (2, N'CF02', N'Cafe Sài Gòn - Quận 7', N'456 Nguyễn Lương Bằng, Q.7, TP.HCM', N'0282345678', N'Active'),
    (3, N'CF03', N'Cafe Sài Gòn - Bình Thạnh', N'789 Xô Viết Nghệ Tĩnh, Bình Thạnh, TP.HCM', N'0283456789', N'Active');
    SET IDENTITY_INSERT dbo.Stores OFF;
    PRINT N'Stores: 3 rows inserted.';
END
GO

-- =============================================
-- 4. Users (PasswordHash: Backend hash "123456" bằng BCrypt; PasswordSalt NULL = salt trong hash)
-- PasswordHashVersion = 1 (BCrypt). Backend nên cập nhật hash khi đổi mật khẩu.
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.Users)
BEGIN
    SET IDENTITY_INSERT dbo.Users ON;
    INSERT INTO dbo.Users (Id, Email, PasswordHash, PasswordSalt, PasswordHashVersion, Name, Phone, Role, StoreId, SupplierId, Status) VALUES
    (1, N'admin@cafe.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Admin Cafe', N'0900000001', N'Admin', NULL, NULL, N'Active'),
    (2, N'q1@cafe.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Nguyễn Văn An', N'0900000002', N'StoreUser', 1, NULL, N'Active'),
    (3, N'q7@cafe.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Trần Thị Bình', N'0900000003', N'StoreUser', 2, NULL, N'Active'),
    (4, N'bt@cafe.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Lê Thị Hương', N'0900000004', N'StoreUser', 3, NULL, N'Active'),
    (5, N'ncc_caphe@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Lê Văn Cường', N'0911000001', N'SupplierUser', NULL, 1, N'Active'),
    (6, N'ncc_sua@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Phạm Thị Dung', N'0911000002', N'SupplierUser', NULL, 2, N'Active'),
    (7, N'ncc_syrup@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Hoàng Văn Em', N'0911000003', N'SupplierUser', NULL, 3, N'Active'),
    (8, N'ncc_banh@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Võ Minh Tuấn', N'0911000004', N'SupplierUser', NULL, 4, N'Active'),
    (9, N'ncc_vattu@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Đặng Thị Lan', N'0911000005', N'SupplierUser', NULL, 5, N'Active'),
    (10, N'ncc_caphe2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Nguyễn Thị Hoa', N'0911000011', N'SupplierUser', NULL, 1, N'Active'),
    (11, N'ncc_sua2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Trần Văn Đức', N'0911000012', N'SupplierUser', NULL, 2, N'Active'),
    (12, N'ncc_syrup2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Lê Thị Mai', N'0911000013', N'SupplierUser', NULL, 3, N'Active'),
    (13, N'ncc_banh2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Phạm Văn Hùng', N'0911000014', N'SupplierUser', NULL, 4, N'Active'),
    (14, N'ncc_vattu2@supplier.vn', N'$2a$10$N9qo8uLOickgx2ZMRZoMy.MqrqYQUYpT7/2QqeqdK.StQK4o6LqHy', NULL, 1, N'Hoàng Thị Nga', N'0911000015', N'SupplierUser', NULL, 5, N'Active');
    SET IDENTITY_INSERT dbo.Users OFF;
    PRINT N'Users: 14 rows inserted. (Password demo: 123456 - BCrypt). SupplierUser: 10 accounts (5 NCC x 2 user).';
END
GO

-- =============================================
-- 5. Products
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.Products)
BEGIN
    SET IDENTITY_INSERT dbo.Products ON;
    INSERT INTO dbo.Products (Id, Code, Name, SupplierId, CategoryId, Unit, Price, Status) VALUES
    (1, N'CF001', N'Cà phê Arabica rang xay 1kg', 1, 1, N'túi', 280000, N'Active'),
    (2, N'CF002', N'Cà phê Robusta Premium 1kg', 1, 1, N'túi', 195000, N'Active'),
    (3, N'CF003', N'Espresso blend 500g', 1, 1, N'hộp', 320000, N'Active'),
    (4, N'TR001', N'Trà Earl Grey túi lọc 100 gói', 1, 2, N'hộp', 85000, N'Active'),
    (5, N'SU001', N'Sữa tươi có đường 1L', 2, 3, N'thùng', 280000, N'Active'),
    (6, N'SU002', N'Sữa đặc Ông Thọ 380g', 2, 3, N'thùng', 320000, N'Active'),
    (7, N'SU003', N'Kem whipping 1L', 2, 3, N'hộp', 185000, N'Active'),
    (8, N'SY001', N'Syrup Caramel Monin 700ml', 3, 4, N'chai', 245000, N'Active'),
    (9, N'SY002', N'Syrup Chocolate Monin 700ml', 3, 4, N'chai', 245000, N'Active'),
    (10, N'SY003', N'Sốt caramel chai 1L', 3, 4, N'chai', 95000, N'Active'),
    (11, N'BH001', N'Bánh croissant', 4, 5, N'thùng', 120000, N'Active'),
    (12, N'BH002', N'Bánh muffin chocolate', 4, 5, N'thùng', 150000, N'Active'),
    (13, N'VT001', N'Ly giấy takeaway 12oz 100c', 3, 6, N'bịch', 85000, N'Active'),
    (14, N'VT002', N'Ống hút giấy 500 ống', 3, 6, N'bịch', 65000, N'Active'),
    (15, N'CF004', N'Cà phê Moka Đắk Lắk 500g', 1, 1, N'túi', 350000, N'Active'),
    (16, N'CF005', N'Cà phê hòa tan 3in1 gói 25 gói', 1, 1, N'thùng', 180000, N'Active'),
    (17, N'TR002', N'Trà đen Ceylon 100 gói', 1, 2, N'hộp', 95000, N'Active'),
    (18, N'TR003', N'Trà xanh matcha 200g', 1, 2, N'hộp', 220000, N'Active'),
    (19, N'SU004', N'Sữa tươi không đường 1L', 2, 3, N'thùng', 265000, N'Active'),
    (20, N'SU005', N'Kem béo nguyên chất 35% 1L', 2, 3, N'hộp', 195000, N'Active'),
    (21, N'SY004', N'Syrup Vanilla Monin 700ml', 3, 4, N'chai', 245000, N'Active'),
    (22, N'SY005', N'Syrup Hazelnut 700ml', 3, 4, N'chai', 255000, N'Active'),
    (23, N'BH003', N'Bánh bông lan cuộn', 4, 5, N'thùng', 135000, N'Active'),
    (24, N'BH004', N'Bánh cookie socola', 4, 5, N'gói', 85000, N'Active'),
    (25, N'VT003', N'Ly nhựa PP 16oz 50c', 3, 6, N'bịch', 72000, N'Active'),
    (26, N'VT004', N'Nắp ly nhựa 16oz 100c', 3, 6, N'bịch', 45000, N'Active'),
    (27, N'VT005', N'Túi giấy kraft 100 túi', 3, 6, N'cuộn', 55000, N'Active'),
    (28, N'CF006', N'Decaf espresso 500g', 1, 1, N'hộp', 380000, N'Active');
    SET IDENTITY_INSERT dbo.Products OFF;
    PRINT N'Products: 28 rows inserted.';
END
GO

-- =============================================
-- 6. Orders (đơn mẫu cho UI)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.Orders)
BEGIN
    SET IDENTITY_INSERT dbo.Orders ON;
    INSERT INTO dbo.Orders (Id, StoreId, Status, OrderDate, OverallExpectedDate, TotalItemCount, TotalAmount, CreatedBy, CreatedDate, IsDeleted) VALUES
    (1, 1, N'Pending', N'2025-02-20', N'2025-03-01', 0, 0, 2, SYSUTCDATETIME(), 0),
    (2, 1, N'Accepted', N'2025-02-22', N'2025-03-05', 0, 0, 2, SYSUTCDATETIME(), 0),
    (3, 2, N'Completed', N'2025-02-15', N'2025-02-25', 0, 0, 3, SYSUTCDATETIME(), 0),
    (4, 1, N'Pending', N'2025-02-28', NULL, 0, 0, 2, SYSUTCDATETIME(), 0),
    (5, 3, N'Rejected', N'2025-02-10', NULL, 0, 0, 4, SYSUTCDATETIME(), 0);
    SET IDENTITY_INSERT dbo.Orders OFF;
    PRINT N'Orders: 5 rows (Pending|Rejected|Accepted|Completed).';
END
GO

-- =============================================
-- 7. OrderSuppliers (đơn theo NCC - trigger sẽ cập nhật TotalAmount khi có OrderItems)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.OrderSuppliers)
BEGIN
    SET IDENTITY_INSERT dbo.OrderSuppliers ON;
    INSERT INTO dbo.OrderSuppliers (Id, OrderId, SupplierId, Status, ExpectedDeliveryDate, ActualDeliveryDate, ConfirmDate, TotalAmount, PaymentStatus) VALUES
    (1, 1, 1, N'Pending', N'2025-02-28', NULL, NULL, 0, N'Unpaid'),
    (2, 1, 2, N'Pending', N'2025-03-01', NULL, NULL, 0, N'Unpaid'),
    (3, 2, 1, N'Accepted', N'2025-03-05', NULL, N'2025-02-23', 0, N'Unpaid'),
    (4, 2, 3, N'Delivering', N'2025-03-06', NULL, N'2025-02-23', 0, N'Unpaid'),
    (5, 3, 1, N'Delivered', N'2025-02-25', N'2025-02-24', N'2025-02-20', 0, N'Unpaid'),
    (6, 3, 2, N'Delivered', N'2025-02-25', N'2025-02-25', N'2025-02-21', 0, N'Unpaid'),
    (7, 3, 3, N'Delivered', N'2025-02-26', N'2025-02-26', N'2025-02-22', 0, N'Unpaid'),
    (8, 5, 1, N'Rejected', NULL, NULL, NULL, 0, N'Unpaid');
    SET IDENTITY_INSERT dbo.OrderSuppliers OFF;
    PRINT N'OrderSuppliers: 8 rows (Pending|Accepted|Rejected|Delivering|Delivered).';
END
GO

-- =============================================
-- 8. OrderItems (trigger cập nhật OrderSuppliers.TotalAmount và Orders.TotalAmount)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.OrderItems)
BEGIN
    SET IDENTITY_INSERT dbo.OrderItems ON;
    INSERT INTO dbo.OrderItems (Id, OrderSupplierId, ProductId, ProductName, Quantity, Unit, Price, DiscountAmount, TaxPercent, TaxAmount) VALUES
    -- Order 1 - OS 1 (NCC Cà phê)
    (1, 1, 1, N'Cà phê Arabica rang xay 1kg', 5, N'túi', 280000, 0, 0, 0),
    (2, 1, 2, N'Cà phê Robusta Premium 1kg', 3, N'túi', 195000, 0, 0, 0),
    -- Order 1 - OS 2 (NCC Sữa)
    (3, 2, 5, N'Sữa tươi có đường 1L', 2, N'thùng', 280000, 0, 0, 0),
    (4, 2, 6, N'Sữa đặc Ông Thọ 380g', 1, N'thùng', 320000, 0, 0, 0),
    -- Order 2 - OS 3
    (5, 3, 1, N'Cà phê Arabica rang xay 1kg', 10, N'túi', 280000, 0, 0, 0),
    (6, 3, 3, N'Espresso blend 500g', 4, N'hộp', 320000, 0, 0, 0),
    -- Order 2 - OS 4
    (7, 4, 8, N'Syrup Caramel Monin 700ml', 6, N'chai', 245000, 0, 0, 0),
    -- Order 3 - OS 5, 6, 7 (đơn hoàn thành)
    (8, 5, 1, N'Cà phê Arabica rang xay 1kg', 8, N'túi', 280000, 0, 0, 0),
    (9, 5, 2, N'Cà phê Robusta Premium 1kg', 5, N'túi', 195000, 0, 0, 0),
    (10, 6, 5, N'Sữa tươi có đường 1L', 4, N'thùng', 280000, 0, 0, 0),
    (11, 6, 7, N'Kem whipping 1L', 2, N'hộp', 185000, 0, 0, 0),
    (12, 7, 8, N'Syrup Caramel Monin 700ml', 3, N'chai', 245000, 0, 0, 0),
    (13, 7, 9, N'Syrup Chocolate Monin 700ml', 3, N'chai', 245000, 0, 0, 0),
    -- Order 5 (Rejected) - OS 8
    (14, 8, 1, N'Cà phê Arabica rang xay 1kg', 2, N'túi', 280000, 0, 0, 0);
    SET IDENTITY_INSERT dbo.OrderItems OFF;
    PRINT N'OrderItems: 14 rows inserted. (Totals updated by trigger)';
END
GO

-- =============================================
-- 9. ReceiveImages (ảnh mẫu - 1 đơn đã nhận hàng)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.ReceiveImages)
BEGIN
    SET IDENTITY_INSERT dbo.ReceiveImages ON;
    INSERT INTO dbo.ReceiveImages (Id, OrderSupplierId, Type, ImageUrl, FileName, Description) VALUES
    (1, 5, N'received', N'/uploads/demo-received-1.jpg', N'anh-hang-nhan.jpg', N'Ảnh hàng nhận từ NCC Cà phê'),
    (2, 5, N'invoice', N'/uploads/demo-invoice-1.jpg', N'hoa-don-ky.jpg', N'Hóa đơn đã ký');
    SET IDENTITY_INSERT dbo.ReceiveImages OFF;
    PRINT N'ReceiveImages: 2 rows inserted.';
END
GO

-- =============================================
-- 10. ProductStock (tồn kho mẫu theo cửa hàng)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.ProductStock)
BEGIN
    INSERT INTO dbo.ProductStock (ProductId, StoreId, Quantity, UpdatedAt) VALUES
    (1, 1, 50, SYSUTCDATETIME()),
    (2, 1, 30, SYSUTCDATETIME()),
    (3, 1, 20, SYSUTCDATETIME()),
    (5, 1, 25, SYSUTCDATETIME()),
    (8, 1, 15, SYSUTCDATETIME()),
    (1, 2, 40, SYSUTCDATETIME()),
    (2, 2, 35, SYSUTCDATETIME()),
    (5, 2, 18, SYSUTCDATETIME()),
    (1, 3, 22, SYSUTCDATETIME()),
    (8, 3, 10, SYSUTCDATETIME());
    PRINT N'ProductStock: 10 rows inserted.';
END
GO

-- =============================================
-- 11. StockTransactions (phiếu nhập mẫu - trigger cập nhật ProductStock)
-- =============================================
IF NOT EXISTS (SELECT 1 FROM dbo.StockTransactions)
BEGIN
    SET IDENTITY_INSERT dbo.StockTransactions ON;
    INSERT INTO dbo.StockTransactions (Id, ProductId, StoreId, QuantityDelta, TransactionType, ReferenceOrderId, ReferenceOrderSupplierId, Note, CreatedAt, CreatedBy) VALUES
    (1, 1, 2, 8, N'In', 3, 5, N'Nhập kho từ đơn #3 - NCC Cà phê', DATEADD(day, -5, SYSUTCDATETIME()), 3),
    (2, 2, 2, 5, N'In', 3, 5, N'Nhập kho từ đơn #3', DATEADD(day, -5, SYSUTCDATETIME()), 3),
    (3, 5, 2, 4, N'In', 3, 6, N'Nhập kho từ đơn #3 - NCC Sữa', DATEADD(day, -4, SYSUTCDATETIME()), 3),
    (4, 7, 2, 2, N'In', 3, 6, N'Nhập kho từ đơn #3', DATEADD(day, -4, SYSUTCDATETIME()), 3),
    (5, 8, 2, 3, N'In', 3, 7, N'Nhập kho từ đơn #3 - NCC Syrup', DATEADD(day, -3, SYSUTCDATETIME()), 3),
    (6, 9, 2, 3, N'In', 3, 7, N'Nhập kho từ đơn #3', DATEADD(day, -3, SYSUTCDATETIME()), 3);
    SET IDENTITY_INSERT dbo.StockTransactions OFF;
    PRINT N'StockTransactions: 6 rows inserted. (Trigger updates ProductStock)';
END
GO

-- =============================================
-- 12. SupplierStock (tồn tại NCC - nếu bảng đã có từ 01_Schema / 03)
-- =============================================
IF OBJECT_ID(N'dbo.SupplierStock', N'U') IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.SupplierStock)
BEGIN
    INSERT INTO dbo.SupplierStock (SupplierId, ProductId, Quantity, UpdatedAt) VALUES
    (1, 1, 200, SYSUTCDATETIME()),
    (1, 2, 150, SYSUTCDATETIME()),
    (1, 3, 80, SYSUTCDATETIME()),
    (2, 5, 100, SYSUTCDATETIME()),
    (2, 6, 60, SYSUTCDATETIME()),
    (3, 8, 50, SYSUTCDATETIME()),
    (3, 9, 45, SYSUTCDATETIME());
    PRINT N'SupplierStock: 7 rows inserted.';
END
GO

PRINT N'Seed data completed.';
PRINT N'Login demo: admin@cafe.vn | q1@cafe.vn | ncc_caphe@supplier.vn ... password = 123456';
PRINT N'Orders: Pending|Rejected|Accepted|Completed. OrderSuppliers: Pending|Accepted|Rejected|Delivering|Delivered.';
GO
