-- =============================================
-- Admin Dashboard - Multi-Supplier Order System
-- SQL Server Database Schema (đã bổ sung cải tiến)
-- =============================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'AdminDashboard')
BEGIN
    CREATE DATABASE AdminDashboard
    COLLATE Vietnamese_CI_AS;
END
GO

USE AdminDashboard;
GO
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =============================================
-- DROP tất cả bảng theo thứ tự phụ thuộc (để chạy lại schema trên DB đã có)
-- =============================================
-- Thứ tự: bảng con trước, bảng cha sau (theo FK)
IF OBJECT_ID(N'dbo.OrderStatusHistory', N'U') IS NOT NULL DROP TABLE dbo.OrderStatusHistory;
IF OBJECT_ID(N'dbo.StockTransactions', N'U') IS NOT NULL DROP TABLE dbo.StockTransactions;
IF OBJECT_ID(N'dbo.ProductStock', N'U') IS NOT NULL DROP TABLE dbo.ProductStock;
IF OBJECT_ID(N'dbo.SupplierStock', N'U') IS NOT NULL DROP TABLE dbo.SupplierStock;
IF OBJECT_ID(N'dbo.TR_StockTransactions_UpdateProductStock', N'TR') IS NOT NULL DROP TRIGGER dbo.TR_StockTransactions_UpdateProductStock;
IF OBJECT_ID(N'dbo.TR_OrderItems_RecalcTotals', N'TR') IS NOT NULL DROP TRIGGER dbo.TR_OrderItems_RecalcTotals;
IF OBJECT_ID(N'dbo.TR_OrderSuppliers_RecalcTotals', N'TR') IS NOT NULL DROP TRIGGER dbo.TR_OrderSuppliers_RecalcTotals;
IF OBJECT_ID(N'dbo.OrderItems', N'U') IS NOT NULL DROP TABLE dbo.OrderItems;
IF OBJECT_ID(N'dbo.ReceiveImages', N'U') IS NOT NULL DROP TABLE dbo.ReceiveImages;
IF OBJECT_ID(N'dbo.OrderSuppliers', N'U') IS NOT NULL DROP TABLE dbo.OrderSuppliers;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL DROP TABLE dbo.Products;
-- Bỏ FK tham chiếu Users để có thể DROP Users (Categories/Suppliers/Stores có CreatedBy/UpdatedBy -> Users)
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL BEGIN
    IF OBJECT_ID(N'dbo.FK_Categories_CreatedBy', N'F') IS NOT NULL ALTER TABLE dbo.Categories DROP CONSTRAINT FK_Categories_CreatedBy;
    IF OBJECT_ID(N'dbo.FK_Categories_UpdatedBy', N'F') IS NOT NULL ALTER TABLE dbo.Categories DROP CONSTRAINT FK_Categories_UpdatedBy;
END
IF OBJECT_ID(N'dbo.Suppliers', N'U') IS NOT NULL BEGIN
    IF OBJECT_ID(N'dbo.FK_Suppliers_CreatedBy', N'F') IS NOT NULL ALTER TABLE dbo.Suppliers DROP CONSTRAINT FK_Suppliers_CreatedBy;
    IF OBJECT_ID(N'dbo.FK_Suppliers_UpdatedBy', N'F') IS NOT NULL ALTER TABLE dbo.Suppliers DROP CONSTRAINT FK_Suppliers_UpdatedBy;
END
IF OBJECT_ID(N'dbo.Stores', N'U') IS NOT NULL BEGIN
    IF OBJECT_ID(N'dbo.FK_Stores_CreatedBy', N'F') IS NOT NULL ALTER TABLE dbo.Stores DROP CONSTRAINT FK_Stores_CreatedBy;
    IF OBJECT_ID(N'dbo.FK_Stores_UpdatedBy', N'F') IS NOT NULL ALTER TABLE dbo.Stores DROP CONSTRAINT FK_Stores_UpdatedBy;
END
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL BEGIN
    IF OBJECT_ID(N'dbo.FK_Users_Store', N'F') IS NOT NULL ALTER TABLE dbo.Users DROP CONSTRAINT FK_Users_Store;
    IF OBJECT_ID(N'dbo.FK_Users_Supplier', N'F') IS NOT NULL ALTER TABLE dbo.Users DROP CONSTRAINT FK_Users_Supplier;
    DROP TABLE dbo.Users;
END
IF OBJECT_ID(N'dbo.Stores', N'U') IS NOT NULL DROP TABLE dbo.Stores;
IF OBJECT_ID(N'dbo.Suppliers', N'U') IS NOT NULL DROP TABLE dbo.Suppliers;
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL DROP TABLE dbo.Categories;
GO

-- =============================================
-- 1. Categories (Danh mục)
-- Cải tiến: CreatedBy, UpdatedBy, CreatedAt, UpdatedAt (audit) - FK thêm sau khi có Users
-- =============================================
CREATE TABLE dbo.Categories (
    Id         INT             NOT NULL IDENTITY(1,1),
    Name       NVARCHAR(200)   NOT NULL,
    Description NVARCHAR(500)   NULL,
    CreatedBy  INT             NULL,
    UpdatedBy  INT             NULL,
    CreatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Categories PRIMARY KEY CLUSTERED (Id)
);
GO

-- =============================================
-- 2. Suppliers (Nhà cung cấp)
-- Cải tiến: CreatedBy, UpdatedBy, CreatedAt, UpdatedAt (audit)
-- =============================================
IF OBJECT_ID(N'dbo.Suppliers', N'U') IS NOT NULL
    DROP TABLE dbo.Suppliers;
GO

CREATE TABLE dbo.Suppliers (
    Id         INT             NOT NULL IDENTITY(1,1),
    Code       NVARCHAR(20)    NOT NULL,
    Name       NVARCHAR(300)   NOT NULL,
    Contact    NVARCHAR(50)    NULL,
    Email      NVARCHAR(100)   NULL,
    Address    NVARCHAR(500)   NULL,
    Status     NVARCHAR(20)    NOT NULL DEFAULT N'Active',
    CreatedBy  INT             NULL,
    UpdatedBy  INT             NULL,
    CreatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Suppliers PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT UQ_Suppliers_Code UNIQUE (Code),
    CONSTRAINT CK_Suppliers_Status CHECK (Status IN (N'Active', N'Inactive'))
);
GO

CREATE INDEX IX_Suppliers_Status ON dbo.Suppliers(Status);
GO

-- =============================================
-- 3. Stores (Cửa hàng)
-- Cải tiến: CreatedBy, UpdatedBy, CreatedAt, UpdatedAt (audit)
-- =============================================
IF OBJECT_ID(N'dbo.Stores', N'U') IS NOT NULL
    DROP TABLE dbo.Stores;
GO

CREATE TABLE dbo.Stores (
    Id         INT             NOT NULL IDENTITY(1,1),
    Code       NVARCHAR(20)    NOT NULL,
    Name       NVARCHAR(300)   NOT NULL,
    Address    NVARCHAR(500)   NULL,
    Phone      NVARCHAR(50)    NULL,
    Status     NVARCHAR(20)    NOT NULL DEFAULT N'Active',
    CreatedBy  INT             NULL,
    UpdatedBy  INT             NULL,
    CreatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Stores PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT UQ_Stores_Code UNIQUE (Code),
    CONSTRAINT CK_Stores_Status CHECK (Status IN (N'Active', N'Inactive'))
);
GO

-- =============================================
-- 4. Users (Người dùng - chuẩn hóa bảo mật mật khẩu)
-- =============================================
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL
    DROP TABLE dbo.Users;
GO

CREATE TABLE dbo.Users (
    Id                 INT             NOT NULL IDENTITY(1,1),
    Email              NVARCHAR(100)   NOT NULL,
    PasswordHash       NVARCHAR(256)   NULL,
    PasswordSalt       NVARCHAR(128)   NULL,
    PasswordHashVersion TINYINT        NOT NULL DEFAULT 1,
    Name               NVARCHAR(200)   NOT NULL,
    Phone              NVARCHAR(50)    NULL,
    Role               NVARCHAR(20)    NOT NULL,
    StoreId            INT             NULL,
    SupplierId         INT             NULL,
    Status             NVARCHAR(20)    NOT NULL DEFAULT N'Active',
    CreatedAt          DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt          DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    RowVersion         ROWVERSION      NOT NULL,
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Role CHECK (Role IN (N'Admin', N'StoreUser', N'SupplierUser')),
    CONSTRAINT CK_Users_Status CHECK (Status IN (N'Active', N'Inactive')),
    CONSTRAINT FK_Users_Store FOREIGN KEY (StoreId) REFERENCES dbo.Stores(Id),
    CONSTRAINT FK_Users_Supplier FOREIGN KEY (SupplierId) REFERENCES dbo.Suppliers(Id)
);
GO

CREATE INDEX IX_Users_StoreId ON dbo.Users(StoreId);
CREATE INDEX IX_Users_SupplierId ON dbo.Users(SupplierId);
CREATE INDEX IX_Users_Status ON dbo.Users(Status);
GO

-- =============================================
-- 5. Products (Sản phẩm)
-- =============================================
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
    DROP TABLE dbo.Products;
GO

CREATE TABLE dbo.Products (
    Id         INT             NOT NULL IDENTITY(1,1),
    Code       NVARCHAR(30)    NOT NULL,
    Name       NVARCHAR(300)   NOT NULL,
    SupplierId INT             NOT NULL,
    CategoryId INT             NOT NULL,
    Unit       NVARCHAR(30)    NOT NULL DEFAULT N'cái',
    Price      DECIMAL(18,0)   NOT NULL DEFAULT 0,
    Status     NVARCHAR(20)    NOT NULL DEFAULT N'Active',
    CreatedBy  INT             NULL,
    UpdatedBy  INT             NULL,
    CreatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt  DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT UQ_Products_Code UNIQUE (Code),
    CONSTRAINT CK_Products_Status CHECK (Status IN (N'Active', N'Inactive')),
    CONSTRAINT FK_Products_Supplier FOREIGN KEY (SupplierId) REFERENCES dbo.Suppliers(Id),
    CONSTRAINT FK_Products_Category FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(Id)
);
GO

CREATE INDEX IX_Products_SupplierId ON dbo.Products(SupplierId);
CREATE INDEX IX_Products_CategoryId ON dbo.Products(CategoryId);
CREATE INDEX IX_Products_Status ON dbo.Products(Status);
GO

-- =============================================
-- 6. Orders (Đơn hàng tổng - 1 cửa hàng)
-- Cải tiến: TotalAmount, DueDate, CancelReason/CancelledBy, LastStatusChangedDate, RowVersion, IsDeleted
-- =============================================
CREATE TABLE dbo.Orders (
    Id                     INT             NOT NULL IDENTITY(1,1),
    StoreId                INT             NOT NULL,
    Status                 NVARCHAR(30)    NOT NULL DEFAULT N'Pending',
    OrderDate              DATE            NOT NULL,
    OverallExpectedDate    DATE            NULL,
    DueDate                DATE            NULL,
    CancelAfterDate        DATE            NULL,
    TotalItemCount         INT             NOT NULL DEFAULT 0,
    TotalAmount            DECIMAL(18,0)   NOT NULL DEFAULT 0,
    CreatedBy              INT             NOT NULL,
    CreatedDate            DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    LastStatusChangedDate  DATETIME2(7)    NULL,
    CancelReason           NVARCHAR(500)   NULL,
    CancelledBy            INT             NULL,
    IsDeleted              BIT             NOT NULL DEFAULT 0,
    RowVersion             ROWVERSION      NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CK_Orders_Status CHECK (Status IN (
        N'Pending', N'Rejected', N'Accepted', N'Completed'
    )),
    CONSTRAINT FK_Orders_Store FOREIGN KEY (StoreId) REFERENCES dbo.Stores(Id),
    CONSTRAINT FK_Orders_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(Id),
    CONSTRAINT FK_Orders_CancelledBy FOREIGN KEY (CancelledBy) REFERENCES dbo.Users(Id)
);
GO

CREATE INDEX IX_Orders_StoreId ON dbo.Orders(StoreId);
CREATE INDEX IX_Orders_Status ON dbo.Orders(Status);
CREATE INDEX IX_Orders_OrderDate ON dbo.Orders(OrderDate);
CREATE INDEX IX_Orders_CreatedBy ON dbo.Orders(CreatedBy);
CREATE INDEX IX_Orders_IsDeleted ON dbo.Orders(IsDeleted);
GO

-- =============================================
-- 7. OrderSuppliers (Đơn theo từng NCC)
-- Cải tiến: TotalAmount, LastStatusChangedDate, RowVersion, Discount
-- =============================================
CREATE TABLE dbo.OrderSuppliers (
    Id                    INT             NOT NULL IDENTITY(1,1),
    OrderId               INT             NOT NULL,
    SupplierId            INT             NOT NULL,
    Status                NVARCHAR(20)    NOT NULL DEFAULT N'Pending',
    ExpectedDeliveryDate  DATE            NULL,
    ActualDeliveryDate    DATE            NULL,
    ConfirmDate           DATE            NULL,
    Note                  NVARCHAR(500)   NULL,
    TotalAmount           DECIMAL(18,0)   NOT NULL DEFAULT 0,
    DiscountAmount        DECIMAL(18,0)   NOT NULL DEFAULT 0,
    DiscountPercent       DECIMAL(5,2)    NOT NULL DEFAULT 0,
    TaxAmount             DECIMAL(18,0)   NOT NULL DEFAULT 0,
    PaymentStatus         NVARCHAR(20)    NOT NULL DEFAULT N'Unpaid',
    PaidAmount            DECIMAL(18,0)   NOT NULL DEFAULT 0,
    PaidDate              DATE            NULL,
    ReceivedBy            INT             NULL,
    ReceivedDate          DATETIME2(7)    NULL,
    LastStatusChangedDate DATETIME2(7)    NULL,
    IsLate                AS (CAST(CASE WHEN ActualDeliveryDate IS NOT NULL AND ExpectedDeliveryDate IS NOT NULL AND ActualDeliveryDate > ExpectedDeliveryDate THEN 1 ELSE 0 END AS BIT)) PERSISTED,
    DeliveryDelayDays     AS (CASE WHEN ActualDeliveryDate IS NOT NULL AND ExpectedDeliveryDate IS NOT NULL AND ActualDeliveryDate > ExpectedDeliveryDate THEN DATEDIFF(day, ExpectedDeliveryDate, ActualDeliveryDate) ELSE 0 END) PERSISTED,
    RowVersion            ROWVERSION      NOT NULL,
    CONSTRAINT PK_OrderSuppliers PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CK_OrderSuppliers_Status CHECK (Status IN (
        N'Pending', N'Accepted', N'Rejected', N'Delivering', N'Delivered'
    )),
    CONSTRAINT CK_OrderSuppliers_PaymentStatus CHECK (PaymentStatus IN (N'Unpaid', N'Partial', N'Paid', N'Overpaid')),
    CONSTRAINT FK_OrderSuppliers_Order FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderSuppliers_Supplier FOREIGN KEY (SupplierId) REFERENCES dbo.Suppliers(Id),
    CONSTRAINT FK_OrderSuppliers_ReceivedBy FOREIGN KEY (ReceivedBy) REFERENCES dbo.Users(Id)
);
GO

CREATE INDEX IX_OrderSuppliers_OrderId ON dbo.OrderSuppliers(OrderId);
CREATE INDEX IX_OrderSuppliers_SupplierId ON dbo.OrderSuppliers(SupplierId);
CREATE INDEX IX_OrderSuppliers_Status ON dbo.OrderSuppliers(Status);
CREATE INDEX IX_OrderSuppliers_IsLate ON dbo.OrderSuppliers(IsLate);
GO

-- =============================================
-- 8. OrderItems (Chi tiết sản phẩm trong đơn NCC)
-- Cải tiến: CHECK Quantity > 0, Price >= 0; DiscountAmount
-- =============================================
CREATE TABLE dbo.OrderItems (
    Id              INT             NOT NULL IDENTITY(1,1),
    OrderSupplierId INT             NOT NULL,
    ProductId       INT             NOT NULL,
    ProductName     NVARCHAR(300)   NOT NULL,
    Quantity        INT             NOT NULL,
    Unit            NVARCHAR(30)    NOT NULL,
    Price           DECIMAL(18,0)   NOT NULL,
    DiscountAmount  DECIMAL(18,0)   NOT NULL DEFAULT 0,
    TaxPercent      DECIMAL(5,2)    NOT NULL DEFAULT 0,
    TaxAmount       DECIMAL(18,0)   NOT NULL DEFAULT 0,
    CONSTRAINT PK_OrderItems PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_Price CHECK (Price >= 0),
    CONSTRAINT FK_OrderItems_OrderSupplier FOREIGN KEY (OrderSupplierId) REFERENCES dbo.OrderSuppliers(Id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItems_Product FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id)
);
GO

CREATE INDEX IX_OrderItems_OrderSupplierId ON dbo.OrderItems(OrderSupplierId);
GO

-- =============================================
-- 9. ReceiveImages (Ảnh Store gửi khi xác nhận nhận hàng)
-- Cải tiến: Description
-- =============================================
CREATE TABLE dbo.ReceiveImages (
    Id              INT             NOT NULL IDENTITY(1,1),
    OrderSupplierId INT             NOT NULL,
    Type            NVARCHAR(20)    NOT NULL,
    ImageUrl        NVARCHAR(500)   NOT NULL,
    FileName        NVARCHAR(255)   NULL,
    Description     NVARCHAR(500)   NULL,
    CreatedAt       DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ReceiveImages PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CK_ReceiveImages_Type CHECK (Type IN (N'received', N'invoice')),
    CONSTRAINT FK_ReceiveImages_OrderSupplier FOREIGN KEY (OrderSupplierId) REFERENCES dbo.OrderSuppliers(Id) ON DELETE CASCADE
);
GO

CREATE INDEX IX_ReceiveImages_OrderSupplierId ON dbo.ReceiveImages(OrderSupplierId);
GO

-- =============================================
-- 10. OrderStatusHistory (Lịch sử thay đổi trạng thái đơn)
-- =============================================
CREATE TABLE dbo.OrderStatusHistory (
    Id              INT             NOT NULL IDENTITY(1,1),
    OrderId         INT             NOT NULL,
    OrderSupplierId INT             NULL,
    OldStatus       NVARCHAR(30)    NULL,
    NewStatus       NVARCHAR(30)    NOT NULL,
    ChangedBy       INT             NOT NULL,
    ChangedDate     DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    Note            NVARCHAR(500)   NULL,
    CONSTRAINT PK_OrderStatusHistory PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT FK_OrderStatusHistory_Order FOREIGN KEY (OrderId) REFERENCES dbo.Orders(Id) ON DELETE CASCADE,
    CONSTRAINT FK_OrderStatusHistory_OrderSupplier FOREIGN KEY (OrderSupplierId) REFERENCES dbo.OrderSuppliers(Id) ON DELETE NO ACTION,
    CONSTRAINT FK_OrderStatusHistory_ChangedBy FOREIGN KEY (ChangedBy) REFERENCES dbo.Users(Id)
);
GO

CREATE INDEX IX_OrderStatusHistory_OrderId ON dbo.OrderStatusHistory(OrderId);
CREATE INDEX IX_OrderStatusHistory_OrderSupplierId ON dbo.OrderStatusHistory(OrderSupplierId);
CREATE INDEX IX_OrderStatusHistory_ChangedDate ON dbo.OrderStatusHistory(ChangedDate);
GO

-- =============================================
-- 11. ProductStock (Tồn kho theo sản phẩm & cửa hàng)
-- =============================================
CREATE TABLE dbo.ProductStock (
    ProductId   INT             NOT NULL,
    StoreId     INT             NOT NULL,
    Quantity    DECIMAL(18,2)   NOT NULL DEFAULT 0,
    UpdatedAt   DATETIME2(7)    NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ProductStock PRIMARY KEY CLUSTERED (ProductId, StoreId),
    CONSTRAINT CK_ProductStock_Quantity CHECK (Quantity >= 0),
    CONSTRAINT FK_ProductStock_Product FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id),
    CONSTRAINT FK_ProductStock_Store FOREIGN KEY (StoreId) REFERENCES dbo.Stores(Id)
);
GO

CREATE INDEX IX_ProductStock_StoreId ON dbo.ProductStock(StoreId);
GO

-- =============================================
-- 12. StockTransactions (Lịch sử nhập/xuất tồn kho)
-- =============================================
CREATE TABLE dbo.StockTransactions (
    Id                   INT             NOT NULL IDENTITY(1,1),
    ProductId            INT             NOT NULL,
    StoreId              INT             NOT NULL,
    QuantityDelta        DECIMAL(18,2)   NOT NULL,
    TransactionType      NVARCHAR(20)    NOT NULL,
    ReferenceOrderId     INT             NULL,
    ReferenceOrderSupplierId INT        NULL,
    Note                 NVARCHAR(500)   NULL,
    CreatedAt            DATETIME2(7)   NOT NULL DEFAULT SYSUTCDATETIME(),
    CreatedBy            INT             NULL,
    CONSTRAINT PK_StockTransactions PRIMARY KEY CLUSTERED (Id),
    CONSTRAINT CK_StockTransactions_Type CHECK (TransactionType IN (N'In', N'Out', N'Adjust')),
    CONSTRAINT FK_StockTransactions_Product FOREIGN KEY (ProductId) REFERENCES dbo.Products(Id),
    CONSTRAINT FK_StockTransactions_Store FOREIGN KEY (StoreId) REFERENCES dbo.Stores(Id),
    CONSTRAINT FK_StockTransactions_Order FOREIGN KEY (ReferenceOrderId) REFERENCES dbo.Orders(Id),
    CONSTRAINT FK_StockTransactions_OrderSupplier FOREIGN KEY (ReferenceOrderSupplierId) REFERENCES dbo.OrderSuppliers(Id),
    CONSTRAINT FK_StockTransactions_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(Id)
);
GO

CREATE INDEX IX_StockTransactions_ProductStore ON dbo.StockTransactions(ProductId, StoreId);
CREATE INDEX IX_StockTransactions_CreatedAt ON dbo.StockTransactions(CreatedAt);
GO

-- =============================================
-- 12b. SupplierStock (Tồn kho tại NCC - NCC xem hàng tồn để quyết định gửi đơn)
-- =============================================
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
GO
CREATE INDEX IX_SupplierStock_SupplierId ON dbo.SupplierStock(SupplierId);
GO

-- =============================================
-- 12c. TRIGGER: Khi thêm StockTransactions → cập nhật ProductStock (nhập/xuất/điều chỉnh)
-- =============================================
IF OBJECT_ID(N'dbo.TR_StockTransactions_UpdateProductStock', N'TR') IS NOT NULL DROP TRIGGER dbo.TR_StockTransactions_UpdateProductStock;
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

-- =============================================
-- 13. TRIGGER: Tự động cập nhật TotalAmount (OrderItems -> OrderSuppliers -> Orders)
-- Công thức: dòng = Quantity * (Price - DiscountAmount/Quantity) + TaxAmount → đơn giản: SUM(Quantity*Price - DiscountAmount + TaxAmount)
-- OrderSupplier.TotalAmount = SUM(line) - OrderSupplier.DiscountAmount + OrderSupplier.TaxAmount
-- =============================================
IF OBJECT_ID(N'dbo.TR_OrderItems_RecalcTotals', N'TR') IS NOT NULL DROP TRIGGER dbo.TR_OrderItems_RecalcTotals;
GO

CREATE TRIGGER dbo.TR_OrderItems_RecalcTotals
ON dbo.OrderItems
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @OrderSupplierIds TABLE (Id INT PRIMARY KEY);
    DECLARE @OrderIds TABLE (Id INT PRIMARY KEY);

    INSERT INTO @OrderSupplierIds (Id)
    SELECT DISTINCT OrderSupplierId FROM (SELECT OrderSupplierId FROM inserted UNION SELECT OrderSupplierId FROM deleted) AS d(OrderSupplierId)
    WHERE OrderSupplierId IS NOT NULL;

    UPDATE os
    SET TotalAmount = ISNULL((
        SELECT SUM(oi.Quantity * oi.Price - oi.DiscountAmount + oi.TaxAmount)
        FROM dbo.OrderItems oi
        WHERE oi.OrderSupplierId = os.Id
    ), 0) - os.DiscountAmount + os.TaxAmount
    FROM dbo.OrderSuppliers os
    INNER JOIN @OrderSupplierIds ids ON os.Id = ids.Id;

    INSERT INTO @OrderIds (Id)
    SELECT DISTINCT OrderId FROM dbo.OrderSuppliers WHERE Id IN (SELECT Id FROM @OrderSupplierIds);

    UPDATE o
    SET TotalAmount = ISNULL((
        SELECT SUM(os.TotalAmount) FROM dbo.OrderSuppliers os WHERE os.OrderId = o.Id
    ), 0),
    TotalItemCount = ISNULL((
        SELECT SUM(oi.Quantity) FROM dbo.OrderItems oi
        INNER JOIN dbo.OrderSuppliers os ON oi.OrderSupplierId = os.Id
        WHERE os.OrderId = o.Id
    ), 0)
    FROM dbo.Orders o
    INNER JOIN @OrderIds ids ON o.Id = ids.Id;
END
GO

-- Trigger: khi OrderSuppliers.DiscountAmount hoặc TaxAmount thay đổi, cập nhật lại TotalAmount và Orders
IF OBJECT_ID(N'dbo.TR_OrderSuppliers_RecalcTotals', N'TR') IS NOT NULL DROP TRIGGER dbo.TR_OrderSuppliers_RecalcTotals;
GO

CREATE TRIGGER dbo.TR_OrderSuppliers_RecalcTotals
ON dbo.OrderSuppliers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(DiscountAmount) AND NOT UPDATE(TaxAmount) RETURN;

    DECLARE @OrderSupplierIds TABLE (Id INT PRIMARY KEY);
    INSERT INTO @OrderSupplierIds (Id) SELECT Id FROM inserted;

    UPDATE os
    SET TotalAmount = ISNULL((
        SELECT SUM(oi.Quantity * oi.Price - oi.DiscountAmount + oi.TaxAmount)
        FROM dbo.OrderItems oi
        WHERE oi.OrderSupplierId = os.Id
    ), 0) - os.DiscountAmount + os.TaxAmount
    FROM dbo.OrderSuppliers os
    INNER JOIN @OrderSupplierIds ids ON os.Id = ids.Id;

    UPDATE o
    SET TotalAmount = ISNULL((SELECT SUM(os.TotalAmount) FROM dbo.OrderSuppliers os WHERE os.OrderId = o.Id), 0)
    FROM dbo.Orders o
    WHERE o.Id IN (SELECT OrderId FROM dbo.OrderSuppliers WHERE Id IN (SELECT Id FROM @OrderSupplierIds));
END
GO

-- =============================================
-- 14. FK Audit (CreatedBy, UpdatedBy) cho Categories, Suppliers, Stores, Products
-- =============================================
ALTER TABLE dbo.Categories ADD CONSTRAINT FK_Categories_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(Id);
ALTER TABLE dbo.Categories ADD CONSTRAINT FK_Categories_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES dbo.Users(Id);
ALTER TABLE dbo.Suppliers ADD CONSTRAINT FK_Suppliers_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(Id);
ALTER TABLE dbo.Suppliers ADD CONSTRAINT FK_Suppliers_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES dbo.Users(Id);
ALTER TABLE dbo.Stores ADD CONSTRAINT FK_Stores_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(Id);
ALTER TABLE dbo.Stores ADD CONSTRAINT FK_Stores_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES dbo.Users(Id);
ALTER TABLE dbo.Products ADD CONSTRAINT FK_Products_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Users(Id);
ALTER TABLE dbo.Products ADD CONSTRAINT FK_Products_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES dbo.Users(Id);
GO

PRINT N'Schema created successfully (with improvements).';
GO
