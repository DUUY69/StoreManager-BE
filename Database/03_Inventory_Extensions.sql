-- =============================================
-- Chạy trên DB đã có sẵn: thêm SupplierStock + trigger nhập kho
-- Chạy sau 01_Schema.sql và 02_SeedData.sql (nếu đã tạo DB trước đó)
-- =============================================
USE AdminDashboard;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- Bảng tồn kho tại NCC (NCC xem hàng tồn để quyết định gửi đơn)
IF OBJECT_ID(N'dbo.SupplierStock', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupplierStock (
        SupplierId INT             NOT NULL,
        ProductId  INT             NOT NULL,
        Quantity   DECIMAL(18,2)   NOT NULL DEFAULT 0,
        UpdatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_SupplierStock PRIMARY KEY CLUSTERED (SupplierId, ProductId),
        CONSTRAINT CK_SupplierStock_Quantity CHECK (Quantity >= 0),
        CONSTRAINT FK_SupplierStock_Supplier FOREIGN KEY (SupplierId) REFERENCES dbo.Suppliers(Id) ON DELETE CASCADE,
        CONSTRAINT FK_SupplierStock_Product FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id) ON DELETE CASCADE
    );
    CREATE INDEX IX_SupplierStock_SupplierId ON dbo.SupplierStock(SupplierId);
    PRINT N'Created table SupplierStock.';
END
GO

-- Trigger: khi thêm StockTransactions → cập nhật ProductStock
IF OBJECT_ID(N'dbo.TR_StockTransactions_UpdateProductStock', N'TR') IS NOT NULL
    DROP TRIGGER dbo.TR_StockTransactions_UpdateProductStock;
GO
CREATE TRIGGER dbo.TR_StockTransactions_UpdateProductStock
ON dbo.StockTransactions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    MERGE dbo.ProductStock AS target
    USING (
        SELECT ProductId, StoreId,
               SUM(CASE TransactionType
                   WHEN N'In'     THEN QuantityDelta
                   WHEN N'Out'    THEN -QuantityDelta
                   WHEN N'Adjust' THEN QuantityDelta
                   ELSE 0 END) AS Delta
        FROM inserted
        GROUP BY ProductId, StoreId
    ) AS src ON target.ProductId = src.ProductId AND target.StoreId = src.StoreId
    WHEN MATCHED THEN
        UPDATE SET Quantity = target.Quantity + src.Delta, UpdatedAt = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET AND src.Delta <> 0 THEN
        INSERT (ProductId, StoreId, Quantity, UpdatedAt)
        VALUES (src.ProductId, src.StoreId, src.Delta, SYSUTCDATETIME());
END
GO
PRINT N'Trigger TR_StockTransactions_UpdateProductStock created.';
GO
