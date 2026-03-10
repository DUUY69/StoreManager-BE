# Database SQL Server - Admin Dashboard

## Cấu trúc thư mục

| File | Mô tả |
|------|--------|
| `01_Schema.sql` | Tạo database `AdminDashboard` và toàn bộ bảng (DROP + CREATE), đã bổ sung cải tiến (kèm SupplierStock + trigger nhập kho). |
| `02_SeedData.sql` | Dữ liệu mẫu: Categories, Suppliers, Stores, Users (kèm **Phone**), Products, **Orders**, **OrderSuppliers**, **OrderItems**, ReceiveImages, **ProductStock**, **StockTransactions**, **SupplierStock**. |
| `03_Inventory_Extensions.sql` | Chạy trên DB đã có sẵn: thêm bảng **SupplierStock** (tồn tại NCC) và trigger **TR_StockTransactions_UpdateProductStock** (tự cập nhật ProductStock khi thêm StockTransactions). |
| `04_User_Profile_Add_Phone.sql` | Chạy trên DB đã có: thêm cột **Users.Phone** (NVARCHAR(50)) và cập nhật số điện thoại mẫu cho user seed. Dùng khi nâng cấp DB cũ chưa có Phone. |
| `05_SupplierUser_Extra_Data.sql` | Chạy trên DB đã có 9 user: thêm 5 **SupplierUser** (Id 10–14), mỗi NCC có thêm 1 user phụ. Password: 123456. |

## Cách chạy

**Cách 1 – Script PowerShell (khuyến nghị):**
```powershell
cd BE
.\scripts\Run-DatabaseSetup.ps1
# Hoặc chỉ định server: .\scripts\Run-DatabaseSetup.ps1 -Server "TEN_SERVER\INSTANCE"
```
Script chạy lần lượt `01_Schema.sql`, `02_SeedData.sql`, `03_Inventory_Extensions.sql`. Cần **sqlcmd** (đi kèm SQL Server).

**Cách 2 – Thủ công trong SSMS / Azure Data Studio:**  
1. Mở và chạy **01_Schema.sql** (tạo DB và các bảng).  
2. Chạy **02_SeedData.sql** (chèn dữ liệu mẫu).  
3. (Tùy chọn) Chạy **03_Inventory_Extensions.sql** nếu DB đã tạo trước đó mà chưa có SupplierStock/trigger.

**Lưu ý:** `01_Schema.sql` DROP và tạo lại toàn bộ bảng theo thứ tự phụ thuộc. Không dùng trên DB đang có dữ liệu thật nếu không muốn mất dữ liệu.

## Unicode / tiếng Việt bị lỗi (C� ph�)

Nếu bạn thấy tiếng Việt bị lỗi trong DB (ký tự `�`), nguyên nhân thường là:
- Script `.sql` được lưu sai encoding (ANSI thay vì UTF-8), hoặc
- DB/seed cũ dùng `VARCHAR` / thiếu tiền tố `N'...'` khi insert.

**Đã xử lý trong repo:**
- `scripts/Run-DatabaseSetup.ps1` chạy `sqlcmd` với `-f 65001` (UTF-8).
- Thêm `Database/06_FixUnicode_AllTextColumns.sql` để **chuyển mọi cột text đang là VARCHAR/CHAR/TEXT sang NVARCHAR** (hỗ trợ nâng cấp DB cũ).

**Quan trọng:** Nếu dữ liệu đã bị lưu sai (đã thành `C� ph�`) thì **không thể tự khôi phục** lại đúng tiếng Việt. Cách chuẩn là **chạy lại 01_Schema.sql + 02_SeedData.sql** sau khi đã đảm bảo UTF-8.

---

## Cải tiến đã áp dụng (so với bản gốc)

| # | Vấn đề | Khắc phục trong schema |
|---|--------|-------------------------|
| 1 | Thiếu TotalAmount / TotalPrice | **Orders**: `TotalAmount`. **OrderSuppliers**: `TotalAmount`, `DiscountAmount`, `DiscountPercent`, `TaxAmount`. **OrderItems**: `DiscountAmount`, `TaxPercent`, `TaxAmount`. **Trigger** tự cập nhật TotalAmount từ OrderItems (đã trừ discount, cộng tax). |
| 2 | Không có lịch sử thay đổi trạng thái | Bảng **OrderStatusHistory**. **Orders** / **OrderSuppliers**: `LastStatusChangedDate`. |
| 3 | Users thiếu chuẩn hóa mật khẩu | **Users**: `PasswordSalt`, `PasswordHashVersion` (1 = BCrypt). |
| 4 | Ngày hết hạn đơn | **Orders**: `DueDate`, `CancelAfterDate`. |
| 5 | Lý do hủy đơn | **Orders**: `CancelReason`, `CancelledBy` FK → Users. |
| 6 | Concurrency | **Orders**, **OrderSuppliers**, **Users**: `RowVersion` ROWVERSION. |
| 7 | Quantity & Price | **OrderItems**: `CHECK (Quantity > 0)`, `CHECK (Price >= 0)`. |
| 8 | Discount / Tax | **OrderSuppliers**: `DiscountAmount`, `DiscountPercent`, `TaxAmount`. **OrderItems**: `DiscountAmount`, `TaxPercent`, `TaxAmount`. |
| 9 | Soft delete | **Orders**: `IsDeleted` BIT. |
| 10 | ReceiveImages | **ReceiveImages**: `Description`. |
| 11 | **Người xác nhận nhận hàng** | **OrderSuppliers**: `ReceivedBy` INT FK → Users, `ReceivedDate` DATETIME2. |
| 12 | **Tổng tiền tính discount tự động** | **Trigger** `TR_OrderItems_RecalcTotals`, `TR_OrderSuppliers_RecalcTotals`: TotalAmount = SUM(Quantity*Price - DiscountAmount + TaxAmount) - header discount + header tax. |
| 13 | **Inventory / Stock** | **ProductStock** (ProductId, StoreId, Quantity). **StockTransactions** (ProductId, StoreId, QuantityDelta, TransactionType In/Out/Adjust, ReferenceOrderId, ReferenceOrderSupplierId, CreatedBy). **Trigger TR_StockTransactions_UpdateProductStock**: khi INSERT StockTransactions → MERGE cập nhật ProductStock (In: +, Out: -, Adjust: +). **SupplierStock** (SupplierId, ProductId, Quantity): tồn kho tại NCC để NCC xem hàng tồn khi quyết định gửi đơn. |
| 14 | **Tax / VAT** | **OrderItems**: `TaxPercent`, `TaxAmount`. **OrderSuppliers**: `TaxAmount`. |
| 15 | **Payment Status** | **OrderSuppliers**: `PaymentStatus` (Unpaid/Partial/Paid/Overpaid), `PaidAmount`, `PaidDate`. |
| 16 | **ExpectedDeliveryDate trùng** | **Orders**: cột đổi tên thành `OverallExpectedDate`; chi tiết theo NCC giữ ở **OrderSuppliers**.ExpectedDeliveryDate. API trả `expectedDeliveryDate` từ OverallExpectedDate hoặc từ OrderSuppliers tùy context. |
| 17 | **CreatedBy / UpdatedBy** | **Categories**, **Suppliers**, **Stores**, **Products**: `CreatedBy`, `UpdatedBy` (FK → Users), `CreatedAt`, `UpdatedAt`. |
| 18 | **Giao trễ (báo cáo KPI)** | **OrderSuppliers**: computed `IsLate` (BIT), `DeliveryDelayDays` (số ngày trễ); index `IX_OrderSuppliers_IsLate` cho query đơn giao trễ. |

---

## Mật khẩu demo (Users)

- **PasswordHash**: BCrypt (hash mẫu trong seed). **PasswordSalt**: NULL (BCrypt lưu salt trong chuỗi hash).
- **PasswordHashVersion**: 1 = BCrypt. Khi đổi thuật toán, tăng version và Backend xử lý tương ứng.
- Backend hash mật khẩu **"123456"** và so sánh với `PasswordHash`; khi đổi mật khẩu ghi lại hash mới (và salt nếu dùng riêng).

---

## Sơ đồ quan hệ (tóm tắt)

```
Categories, Suppliers, Stores (CreatedBy, UpdatedBy FK Users; CreatedAt, UpdatedAt)
Users (PasswordSalt, PasswordHashVersion, RowVersion)
Products (FK: SupplierId, CategoryId; CreatedBy, UpdatedBy, CreatedAt, UpdatedAt)
Orders (OverallExpectedDate, TotalAmount, DueDate, CancelReason, CancelledBy, IsDeleted, RowVersion)
  ├── OrderStatusHistory (OrderId, OrderSupplierId, OldStatus, NewStatus, ChangedBy)
  └── OrderSuppliers (ExpectedDeliveryDate, TotalAmount, Discount*, TaxAmount, PaymentStatus, PaidAmount, PaidDate, ReceivedBy, ReceivedDate, RowVersion)
        ├── OrderItems (Quantity, Price, DiscountAmount, TaxPercent, TaxAmount; CHECK Quantity>0, Price>=0)
        └── ReceiveImages (Type, ImageUrl, Description)
ProductStock (ProductId, StoreId, Quantity)  -- tồn kho theo cửa hàng (trigger từ StockTransactions)
StockTransactions (ProductId, StoreId, QuantityDelta, TransactionType In/Out/Adjust, ReferenceOrderId, ReferenceOrderSupplierId, CreatedBy)
  → TR_StockTransactions_UpdateProductStock: cập nhật ProductStock khi thêm phiếu
SupplierStock (SupplierId, ProductId, Quantity)  -- tồn kho tại NCC (NCC xem để quyết định gửi đơn)
```

---

## Trạng thái (Status)

- **Order:** `Draft`, `Submitted`, `Processing`, `PartiallyCompleted`, `Completed`, `Cancelled`
- **OrderSupplier:** `Pending`, `Confirmed`, `Partial`, `Rejected`, `Delivering`, `Delivered`, `Completed`
- **Supplier / Store / User / Product:** `Active`, `Inactive`

---

## Đối chiếu với đánh giá hệ thống (GIỚI THIỆU / TỔNG HỢP)

Schema hiện tại đáp ứng **~95%+** yêu cầu nghiệp vụ (demo FE + luồng đặt hàng đa NCC). Bảng dưới đối chiếu từng mục đánh giá với khả năng DB.

| Yêu cầu / Đánh giá | Đáp ứng schema | Ghi chú |
|-------------------|----------------|--------|
| Đặt hàng đa NCC + tự tách đơn con | ✅ 100% | Orders → OrderSuppliers → OrderItems, FK CASCADE. |
| Theo dõi trạng thái đơn tổng & từng NCC | ✅ | Order.Status, OrderSuppliers.Status; LastStatusChangedDate + **OrderStatusHistory**. |
| Xác nhận nhận hàng + lưu ảnh (received/invoice) | ✅ | **ReceiveImages** (Type, ImageUrl, Description); **ReceivedBy**, **ReceivedDate** trên OrderSuppliers. |
| Phân quyền theo role (Store/Supplier/Admin) | ✅ (BE enforce) | Users.StoreId, Users.SupplierId; filter Orders/OrderSuppliers ở API. |
| CRUD danh mục, NCC, SP, cửa hàng, user | ✅ | Bảng đầy đủ + audit CreatedBy/UpdatedBy. |
| Báo cáo theo NCC / Cửa hàng, lọc ngày | ✅ | TotalAmount, PaidAmount, PaymentStatus, TaxAmount; index OrderDate, IsLate. |
| Audit / lịch sử thay đổi trạng thái | ✅ | **OrderStatusHistory** (OrderId, OrderSupplierId, OldStatus, NewStatus, ChangedBy). |
| Concurrency & bảo mật | ✅ | RowVersion (Orders, OrderSuppliers, Users); PasswordSalt, PasswordHashVersion. |
| **Tồn kho sau khi nhận hàng** | ✅ | **ProductStock**, **StockTransactions** (In/Out/Adjust, ReferenceOrderId, ReferenceOrderSupplierId). |
| **Công nợ / thanh toán NCC** | ✅ | OrderSuppliers: **PaymentStatus**, **PaidAmount**, **PaidDate**. |
| **Thuế VAT** | ✅ | OrderItems: **TaxPercent**, **TaxAmount**; OrderSuppliers: **TaxAmount**. |
| **TotalAmount tự động (discount/tax)** | ✅ | Trigger **TR_OrderItems_RecalcTotals**, **TR_OrderSuppliers_RecalcTotals**. |
| **Flag / ngày giao trễ** | ✅ | OrderSuppliers: computed **IsLate** (BIT), **DeliveryDelayDays** (số ngày trễ); index IsLate. |
| Trigger trạng thái tổng (Order theo đơn con) | ⚠️ BE hoặc trigger | Có thể thêm trigger: khi tất cả OrderSuppliers Completed/Rejected → set Order.Status = Completed; logic phức tạp hơn (PartiallyCompleted) nên implement ở BE. |
| Notification log (ai nhận thông báo) | ❌ Tùy chọn | Có thể bổ sung bảng **NotificationLog** sau nếu cần. |

**Kết luận:** Schema sẵn sàng cho **production phase 1** (đặt hàng, duyệt, giao, nhận + ảnh, báo cáo, audit, kho, công nợ, thuế, giao trễ). Chỉ còn logic cập nhật trạng thái tổng Order theo đơn con (và notification) có thể làm ở BE hoặc bổ sung trigger/ bảng sau.

---

## Gợi ý Backend

- **Tổng tiền:** Trigger tự cập nhật `OrderSuppliers.TotalAmount` và `Orders.TotalAmount` khi OrderItems thay đổi (và khi OrderSuppliers.DiscountAmount/TaxAmount thay đổi). Backend không cần tính tay; khi INSERT/UPDATE OrderItems, trigger chạy.
- **Xác nhận nhận hàng:** Khi Store “xác nhận đã nhận hàng”, cập nhật OrderSupplier: `ReceivedBy = currentUser.Id`, `ReceivedDate = GETUTCDATE()`, Status = Completed (và ghi OrderStatusHistory).
- **OrderStatusHistory:** Mỗi lần đổi Status (Order hoặc OrderSupplier), INSERT 1 dòng vào `OrderStatusHistory`, cập nhật `LastStatusChangedDate`.
- **Optimistic locking:** UPDATE Orders/OrderSuppliers/Users kèm `WHERE Id = @id AND RowVersion = @rowVersion`; nếu @@ROWCOUNT = 0 thì báo conflict.
- **Soft delete:** Xóa đơn nên SET `IsDeleted = 1`; list đơn mặc định `WHERE IsDeleted = 0`.
- **API mapping:** DB `Orders.OverallExpectedDate` → API vẫn trả `expectedDeliveryDate` cho FE. OrderSuppliers vẫn có `expectedDeliveryDate` (chi tiết theo NCC).
- **Tồn kho:** Khi xác nhận nhận hàng (OrderSupplier → Completed), Backend có thể INSERT StockTransactions (Type = In) và cập nhật ProductStock.Quantity.
- **NCC giao trễ:** Báo cáo / dashboard “đơn giao trễ”: query OrderSuppliers với `WHERE IsLate = 1` (hoặc `DeliveryDelayDays > 0`). Cột computed tự tính từ ActualDeliveryDate vs ExpectedDeliveryDate.
