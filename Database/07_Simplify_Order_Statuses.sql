-- =============================================
-- Đơn giản hóa trạng thái đơn tổng & đơn NCC
-- Order: 4 trạng thái — Chờ, Từ chối, Chấp nhận, Hoàn thành
-- OrderSupplier: 5 trạng thái — Chờ, Chấp nhận, Từ chối, Đang giao, Giao hoàn thành
-- =============================================

USE AdminDashboard;
GO

-- 1. Migrate existing Order statuses to new values
UPDATE dbo.Orders
SET Status = CASE
    WHEN Status IN (N'Draft', N'Submitted', N'Pending') THEN N'Pending'
    WHEN Status = N'Cancelled' THEN N'Rejected'
    WHEN Status IN (N'Processing', N'PartiallyCompleted') THEN N'Accepted'
    WHEN Status = N'Completed' THEN N'Completed'
    ELSE N'Pending'
END
WHERE Status NOT IN (N'Pending', N'Rejected', N'Accepted', N'Completed');
GO

-- 2. Migrate existing OrderSupplier statuses to new values
UPDATE dbo.OrderSuppliers
SET Status = CASE
    WHEN Status = N'Pending' THEN N'Pending'
    WHEN Status = N'Confirmed' THEN N'Accepted'
    WHEN Status = N'Rejected' THEN N'Rejected'
    WHEN Status IN (N'Partial', N'Delivering') THEN N'Delivering'
    WHEN Status IN (N'Delivered', N'Completed') THEN N'Delivered'
    ELSE N'Pending'
END
WHERE Status NOT IN (N'Pending', N'Accepted', N'Rejected', N'Delivering', N'Delivered');
GO

-- 3. Drop old CHECK constraints
IF OBJECT_ID(N'dbo.CK_Orders_Status', N'C') IS NOT NULL
    ALTER TABLE dbo.Orders DROP CONSTRAINT CK_Orders_Status;
GO
IF OBJECT_ID(N'dbo.CK_OrderSuppliers_Status', N'C') IS NOT NULL
    ALTER TABLE dbo.OrderSuppliers DROP CONSTRAINT CK_OrderSuppliers_Status;
GO

-- 4. Add new CHECK constraints
ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_Status CHECK (Status IN (N'Pending', N'Rejected', N'Accepted', N'Completed'));
GO
ALTER TABLE dbo.OrderSuppliers ADD CONSTRAINT CK_OrderSuppliers_Status CHECK (Status IN (N'Pending', N'Accepted', N'Rejected', N'Delivering', N'Delivered'));
GO

-- 5. Default for new Orders (Chờ) — drop old Draft default, add Pending
DECLARE @def NVARCHAR(200);
SELECT @def = name FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID(N'dbo.Orders') AND parent_column_id = (SELECT column_id FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Orders') AND name = N'Status');
IF @def IS NOT NULL EXEC(N'ALTER TABLE dbo.Orders DROP CONSTRAINT ' + @def);
ALTER TABLE dbo.Orders ADD CONSTRAINT DF_Orders_Status DEFAULT N'Pending' FOR Status;
GO

PRINT N'07_Simplify_Order_Statuses: Done. Order = Pending|Rejected|Accepted|Completed; OrderSupplier = Pending|Accepted|Rejected|Delivering|Delivered.';
GO
