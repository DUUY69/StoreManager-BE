-- Chỉ sửa CHECK constraint Orders & OrderSuppliers (cho phép Pending, Rejected, Accepted, Completed / Pending, Accepted, Rejected, Delivering, Delivered)
-- Chạy script này nếu chưa chạy 07_Simplify_Order_Statuses.sql

USE AdminDashboard;
GO

-- Bỏ constraint cũ
IF OBJECT_ID(N'dbo.CK_Orders_Status', N'C') IS NOT NULL
    ALTER TABLE dbo.Orders DROP CONSTRAINT CK_Orders_Status;
GO
IF OBJECT_ID(N'dbo.CK_OrderSuppliers_Status', N'C') IS NOT NULL
    ALTER TABLE dbo.OrderSuppliers DROP CONSTRAINT CK_OrderSuppliers_Status;
GO

-- Thêm constraint mới
ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_Status CHECK (Status IN (N'Pending', N'Rejected', N'Accepted', N'Completed'));
GO
ALTER TABLE dbo.OrderSuppliers ADD CONSTRAINT CK_OrderSuppliers_Status CHECK (Status IN (N'Pending', N'Accepted', N'Rejected', N'Delivering', N'Delivered'));
GO

PRINT N'Done. CK_Orders_Status & CK_OrderSuppliers_Status updated.';
GO
