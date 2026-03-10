-- =============================================
-- Xóa tất cả đơn hàng trong DB (để tạo lại từ đầu)
-- Chạy script này trên database AdminDashboard
-- =============================================

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE AdminDashboard;
GO

-- 1. Bỏ tham chiếu đơn trong StockTransactions (tránh lỗi FK khi xóa Order)
UPDATE dbo.StockTransactions SET ReferenceOrderId = NULL, ReferenceOrderSupplierId = NULL WHERE ReferenceOrderId IS NOT NULL OR ReferenceOrderSupplierId IS NOT NULL;
GO

-- 2. Xóa lịch sử trạng thái đơn (tham chiếu OrderId, OrderSupplierId)
DELETE FROM dbo.OrderStatusHistory;
GO

-- 3. Xóa ảnh nhận hàng (theo OrderSupplier)
DELETE FROM dbo.ReceiveImages;
GO

-- 4. Xóa chi tiết dòng đơn (OrderItems)
DELETE FROM dbo.OrderItems;
GO

-- 5. Xóa đơn NCC (OrderSuppliers)
DELETE FROM dbo.OrderSuppliers;
GO

-- 6. Xóa đơn tổng (Orders)
DELETE FROM dbo.Orders;
GO

PRINT N'Đã xóa tất cả đơn hàng (Orders, OrderSuppliers, OrderItems, ReceiveImages, OrderStatusHistory). Có thể tạo đơn mới.';
GO
