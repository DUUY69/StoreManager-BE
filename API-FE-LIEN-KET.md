# API Backend – Liên kết với Frontend (Admin Dashboard)

Tài liệu mô tả các API cần triển khai ở Backend để FE (Multi-Supplier Order System) hoạt động đầy đủ. Các chức năng FE hiện dùng dữ liệu mẫu trong `DataContext`; khi tích hợp BE, FE sẽ gọi các endpoint dưới đây.

---

## 1. Xác thực (Auth)

| Chức năng FE | Mô tả | API cần có |
|--------------|--------|------------|
| **Login** (`Login.jsx`) | Đăng nhập bằng email/password (hiện demo chọn user) | `POST /api/auth/login` |
| **Logout** | Đăng xuất, xóa session/token | `POST /api/auth/logout` (tùy chọn) |
| **Lấy thông tin user hiện tại** | Refresh token / get current user | `GET /api/auth/me` hoặc decode JWT |

### 1.1 POST `/api/auth/login`

**Request body:**
```json
{
  "email": "admin@cafe.vn",
  "password": "***"
}
```

**Response (200):**
```json
{
  "user": {
    "id": 1,
    "email": "admin@cafe.vn",
    "name": "Admin Cafe",
    "role": "Admin",
    "storeId": null,
    "supplierId": null,
    "status": "Active"
  },
  "token": "eyJhbG..."
}
```

**Ghi chú:** FE lưu `token` (Bearer) và `user` (localStorage/context). Role: `Admin` | `StoreUser` | `SupplierUser`. `storeId`/`supplierId` dùng cho phân quyền theo cửa hàng/NCC.

---

## 2. Nhà cung cấp (Suppliers)

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **Suppliers** (`Suppliers.jsx`) | Danh sách + lọc (search, status) | `GET /api/suppliers` |
| | Thêm mới | `POST /api/suppliers` |
| | Sửa | `PUT /api/suppliers/:id` |
| | Xóa | `DELETE /api/suppliers/:id` |

### 2.1 GET `/api/suppliers`

**Query (optional):** `?search=&status=Active|Inactive`

**Response (200):**
```json
[
  {
    "id": 1,
    "code": "NCC01",
    "name": "Công ty Cà phê Trung Nguyên",
    "contact": "0901234567",
    "email": "trungnguyen@supplier.vn",
    "address": "Q.1, TP.HCM",
    "status": "Active"
  }
]
```

### 2.2 POST `/api/suppliers`

**Body:** `{ "code", "name", "contact", "email", "address", "status" }`  
**Response (201):** object supplier (có `id`).

### 2.3 PUT `/api/suppliers/:id`

**Body:** cùng cấu trúc như POST.  
**Response (200):** object supplier cập nhật.

### 2.4 DELETE `/api/suppliers/:id`

**Response (204)** hoặc (200).

---

## 3. Danh mục (Categories)

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **Categories** (`Categories.jsx`) | Danh sách | `GET /api/categories` |
| | Thêm / Sửa / Xóa | `POST /api/categories`, `PUT /api/categories/:id`, `DELETE /api/categories/:id` |

### 3.1 GET `/api/categories`

**Response (200):**
```json
[
  { "id": 1, "name": "Cà phê", "description": "Cà phê hạt, cà phê bột..." }
]
```

### 3.2 POST `/api/categories`  
Body: `{ "name", "description" }`.  
### 3.3 PUT `/api/categories/:id`  
Body: `{ "name", "description" }`.  
### 3.4 DELETE `/api/categories/:id`

---

## 4. Sản phẩm (Products)

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **Products** (`Products.jsx`) | Danh sách + lọc (search, supplierId, categoryId, status) | `GET /api/products` |
| | Thêm / Sửa / Xóa | `POST /api/products`, `PUT /api/products/:id`, `DELETE /api/products/:id` |
| **CreateOrder** | Danh sách sản phẩm active để chọn vào giỏ | `GET /api/products?status=Active` (có thể kèm supplierId, categoryId) |

### 4.1 GET `/api/products`

**Query (optional):** `?search=&supplierId=&categoryId=&status=Active|Inactive`

**Response (200):**
```json
[
  {
    "id": 1,
    "code": "CF001",
    "name": "Cà phê Arabica rang xay 1kg",
    "supplierId": 1,
    "categoryId": 1,
    "unit": "túi",
    "price": 280000,
    "status": "Active"
  }
]
```

### 4.2 POST `/api/products`  
Body: `{ "code", "name", "supplierId", "categoryId", "unit", "price", "status" }`.  
### 4.3 PUT `/api/products/:id`  
Cùng cấu trúc.  
### 4.4 DELETE `/api/products/:id`

---

## 5. Cửa hàng (Stores)

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **Stores** (`Stores.jsx`) | Danh sách, Thêm / Sửa / Xóa | `GET /api/stores`, `POST /api/stores`, `PUT /api/stores/:id`, `DELETE /api/stores/:id` |
| **Users** | Dropdown chọn cửa hàng | `GET /api/stores` |
| **OrderList / OrderDetail** | Lọc theo store, hiển thị tên store | Dùng từ order hoặc `GET /api/stores` |

### 5.1 GET `/api/stores`

**Response (200):**
```json
[
  {
    "id": 1,
    "code": "CF01",
    "name": "Cafe Sài Gòn - Quận 1",
    "address": "123 Nguyễn Huệ, Q.1, TP.HCM",
    "phone": "0281234567",
    "status": "Active"
  }
]
```

### 5.2 POST `/api/stores`  
Body: `{ "code", "name", "address", "phone", "status" }`.  
### 5.3 PUT `/api/stores/:id`  
### 5.4 DELETE `/api/stores/:id`

---

## 6. User

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **Users** (`Users.jsx`) | Danh sách, Thêm / Sửa / Xóa | `GET /api/users`, `POST /api/users`, `PUT /api/users/:id`, `DELETE /api/users/:id` |

### 6.1 GET `/api/users`

**Response (200):**
```json
[
  {
    "id": 1,
    "email": "admin@cafe.vn",
    "name": "Admin Cafe",
    "role": "Admin",
    "storeId": null,
    "supplierId": null,
    "status": "Active"
  }
]
```

### 6.2 POST `/api/users`  
Body: `{ "email", "name", "role", "storeId", "supplierId", "status" }` (password nếu đăng ký mới).  
### 6.3 PUT `/api/users/:id`  
### 6.4 DELETE `/api/users/:id`

---

## 7. Đơn hàng (Orders)

Cấu trúc dữ liệu FE:

- **Order**: đơn tổng (1 cửa hàng). Status: `Draft` | `Submitted` | `Processing` | `PartiallyCompleted` | `Completed` | `Cancelled`.
- **OrderSupplier**: đơn theo từng NCC trong đơn tổng. Status: `Pending` | `Confirmed` | `Partial` | `Rejected` | `Delivering` | `Delivered` | `Completed`.
- **OrderItem**: dòng sản phẩm trong OrderSupplier (productId, quantity, unit, price).

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **CreateOrder** | Tạo đơn từ giỏ (storeId, createdBy, orderSuppliers[] với orderItems[]) | `POST /api/orders` |
| **OrderList** | Danh sách đơn, lọc (status, storeId, supplierId, dateFrom, dateTo); Admin chấp nhận/từ chối đơn Submitted | `GET /api/orders`, `PATCH /api/orders/:id/accept`, `PATCH /api/orders/:id/reject` |
| **OrderDetail** | Chi tiết 1 đơn | `GET /api/orders/:id` |
| **OrderDetail** | Admin: Chấp nhận / Từ chối đơn Submitted | `PATCH /api/orders/:id/accept`, `PATCH /api/orders/:id/reject` |
| **OrderDetail** | Admin: Chấp nhận đơn tổng (đóng đơn) khi tất cả NCC Delivered/Completed | `PATCH /api/orders/:id/confirm-total` |
| **OrderDetail** | Store: Xác nhận đã nhận hàng + upload ảnh (receiveImages) cho 1 OrderSupplier | `PATCH /api/order-suppliers/:id/confirm-receive` (multipart: ảnh received + invoice) |

**Phân quyền:**

- **StoreUser:** chỉ xem/sửa đơn của `storeId` của mình.
- **SupplierUser:** không dùng trực tiếp Order list/detail (dùng Supplier orders).
- **Admin:** xem tất cả, duyệt đơn, confirm đơn tổng.

### 7.1 GET `/api/orders`

**Query:** `?status=&storeId=&supplierId=&dateFrom=&dateTo=`  
Backend nên filter theo role: StoreUser chỉ thấy `storeId = currentUser.storeId`.

**Response (200):**
```json
[
  {
    "id": 1,
    "storeId": 1,
    "storeName": "Cafe Sài Gòn - Quận 1",
    "status": "Completed",
    "orderDate": "2025-02-25",
    "expectedDeliveryDate": "2025-03-01",
    "createdBy": 2,
    "createdDate": "2025-02-25T08:00:00",
    "totalItemCount": 6,
    "orderSuppliers": [
      {
        "id": 101,
        "orderId": 1,
        "supplierId": 1,
        "supplierName": "Công ty Cà phê Trung Nguyên",
        "status": "Completed",
        "expectedDeliveryDate": "2025-02-28",
        "actualDeliveryDate": "2025-02-28",
        "confirmDate": "2025-02-26",
        "note": "",
        "receiveImages": [
          { "id": "img1", "type": "received", "imageUrl": "/uploads/...", "fileName": "anh-hang-nhan.png" },
          { "id": "img2", "type": "invoice", "imageUrl": "/uploads/...", "fileName": "hoa-don.png" }
        ],
        "orderItems": [
          { "id": 1001, "productId": 1, "productName": "Cà phê Arabica...", "quantity": 5, "unit": "túi", "price": 280000 }
        ]
      }
    ]
  }
]
```

### 7.2 GET `/api/orders/:id`

**Response (200):** Một object Order (cùng cấu trúc như phần tử trong mảng trên). Trả 403 nếu StoreUser và order không thuộc store của user.

### 7.3 POST `/api/orders`

**Body (CreateOrder gửi lên):**
```json
{
  "storeId": 1,
  "expectedDeliveryDate": null,
  "orderSuppliers": [
    {
      "supplierId": 1,
      "orderItems": [
        { "productId": 1, "productName": "...", "quantity": 5, "unit": "túi", "price": 280000 }
      ]
    }
  ]
}
```

**Response (201):** Order đã tạo (có `id`, `status: "Submitted"`, `createdBy`, `createdDate`, `totalItemCount`). Backend tự sinh `orderSuppliers[].id`, `orderItems[].id`.

### 7.4 PATCH `/api/orders/:id/accept`

Admin chấp nhận đơn (Submitted → Processing, tất cả OrderSupplier Pending → Confirmed, ghi confirmDate).  
**Response (200):** Order cập nhật.

### 7.5 PATCH `/api/orders/:id/reject`

Admin từ chối đơn (tất cả OrderSupplier → Rejected, Order → Cancelled).  
**Response (200):** Order cập nhật.

### 7.6 PATCH `/api/orders/:id/confirm-total`

Admin đóng đơn: tất cả OrderSupplier đang Delivered → Completed, Order → Completed.  
**Response (200):** Order cập nhật.

### 7.7 PATCH `/api/order-suppliers/:id/confirm-receive`

Store xác nhận đã nhận hàng cho một OrderSupplier (status → Completed), kèm upload ảnh.

**Request:** `multipart/form-data`  
- `received[]`: file ảnh hàng nhận được  
- `invoice[]`: file ảnh hóa đơn  

**Response (200):** OrderSupplier cập nhật (receiveImages có thêm bản ghi mới). Có thể trả luôn Order cha để FE cập nhật context.

### 7.8 POST `/api/order-suppliers/:id/stock-in`

**Nhập kho:** Tạo phiếu nhập (StockTransactions type In) từ các dòng đơn OrderSupplier, cập nhật ProductStock của cửa hàng. Gọi khi Store đã nhận hàng từ NCC (sau hoặc kèm xác nhận nhận hàng).

**Response (200):**
```json
{ "orderSupplierId": 101, "storeId": 1, "transactionsCreated": 2, "message": "Đã nhập kho theo đơn NCC." }
```

---

## 7.9 Kho (Warehouse)

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **Warehouse** | Tồn kho theo cửa hàng | `GET /api/warehouse/stock?storeId=` |
| **Warehouse** | Lịch sử nhập/xuất kho | `GET /api/warehouse/transactions?storeId=&dateFrom=&dateTo=` |

- **GET /api/warehouse/stock** — Query: `storeId` (bắt buộc với StoreUser; Admin có thể xem nhiều store). Response: `[{ productId, productCode, productName, storeId, storeName, quantity, updatedAt }]`.
- **GET /api/warehouse/transactions** — Query: `storeId`, `dateFrom`, `dateTo`. Response: `[{ id, productId, productName, storeId, storeName, quantityDelta, transactionType, referenceOrderId, referenceOrderSupplierId, note, createdAt }]`.

---

## 8. Đơn theo NCC (Supplier Orders)

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **SupplierOrderList** | Danh sách đơn con (OrderSupplier) của NCC đang đăng nhập, lọc status, dateFrom, dateTo | `GET /api/supplier-orders` (hoặc `GET /api/orders?supplierId=current` trả OrderSupplier) |
| **SupplierOrderDetail** | Chi tiết 1 đơn con + cập nhật trạng thái (Confirm, Reject, Partial, Delivering, Delivered) | `GET /api/supplier-orders/:id`, `PATCH /api/supplier-orders/:id/status` |

**Phân quyền:** Chỉ SupplierUser, và chỉ được xem/sửa OrderSupplier có `supplierId === currentUser.supplierId`.

### 8.1 GET `/api/supplier-orders`

**Query:** `?status=&dateFrom=&dateTo=`  
Backend filter theo `currentUser.supplierId`, trả danh sách OrderSupplier (có thể kèm thông tin order cha: storeName, orderId, orderDate).

**Response (200):**
```json
[
  {
    "id": 101,
    "orderId": 1,
    "supplierId": 1,
    "supplierName": "...",
    "status": "Pending",
    "expectedDeliveryDate": "2025-02-28",
    "actualDeliveryDate": null,
    "confirmDate": null,
    "note": "",
    "order": { "id": 1, "storeName": "Cafe Q1", "orderDate": "2025-02-25" },
    "orderItems": [ ... ]
  }
]
```

### 8.2 GET `/api/supplier-orders/:id`

**Response (200):** Một OrderSupplier (cùng cấu trúc, có orderItems). 403 nếu không thuộc NCC của user.

### 8.3 PATCH `/api/supplier-orders/:id/status`

**Body:**
```json
{ "status": "Confirmed" }
```
Hoặc khi báo giao thiếu:
```json
{ "status": "Partial", "note": "Thiếu 2 túi cà phê do hết hàng, giao bù tuần sau" }
```
Trạng thái hợp lệ: `Confirmed` | `Rejected` | `Partial` | `Delivering` | `Delivered`.  
- Khi `Confirmed` → ghi `confirmDate`.  
- Khi `Delivered` → ghi `actualDeliveryDate`.  
- Khi `Partial` → nên gửi kèm `note` (ghi chú giao thiếu); Backend lưu vào OrderSuppliers.Note.  
**Response (200):** OrderSupplier cập nhật (có `status`, `note` nếu gửi).

---

## 9. Báo cáo (Reports)

| Trang FE | Thao tác | API |
|----------|----------|-----|
| **Reports** (`Reports.jsx`) | Lọc theo dateFrom, dateTo; thống kê theo NCC, theo cửa hàng; export CSV (FE có thể làm từ dữ liệu API) | `GET /api/reports/summary` hoặc dùng `GET /api/orders` có filter rồi aggregate ở FE |

Hai hướng:

- **Cách 1:** FE gọi `GET /api/orders?dateFrom=&dateTo=` rồi aggregate (theo NCC, theo store) như hiện FE đang làm với mock data.
- **Cách 2:** BE cung cấp sẵn API báo cáo.

### 9.1 GET `/api/reports/summary` (tùy chọn)

**Query:** `?dateFrom=&dateTo=`

**Response (200):**
```json
{
  "totalOrders": 15,
  "totalOrderSuppliers": 28,
  "completedOrderSuppliers": 20,
  "bySupplier": [
    { "id": 1, "name": "Trung Nguyên", "totalOrders": 8, "completed": 6, "totalItems": 120 }
  ],
  "byStore": [
    { "id": 1, "name": "Cafe Q1", "totalOrders": 10 }
  ]
}
```

---

## 10. Dashboard Home

| Trang FE | Dữ liệu cần | API |
|----------|-------------|-----|
| **DashboardHome** | Tổng đơn, đơn đang giao, NCC giao trễ, đơn gần đây, biểu đồ theo tháng/trạng thái/tuần | Có thể chỉ cần `GET /api/orders` (và filter theo store nếu StoreUser); FE aggregate như hiện tại. Hoặc BE có `GET /api/dashboard/stats?dateFrom=&dateTo=` trả sẵn số liệu + đơn gần đây. |

### 10.1 GET `/api/dashboard/stats` (tùy chọn)

**Query:** `?dateFrom=&dateTo=` (có thể mặc định tháng hiện tại).

**Response (200):**
```json
{
  "totalOrders": 20,
  "deliveringCount": 3,
  "lateCount": 1,
  "recentOrders": [ { "id", "storeName", "orderDate", "status" }, ... ]
}
```

Admin: toàn hệ thống. StoreUser: theo storeId. SupplierUser: có thể dùng supplier-orders để đếm Pending, giao hôm nay.

---

## 11. Tổng hợp endpoint theo module

| Module | Method | Endpoint | Ghi chú |
|--------|--------|----------|--------|
| Auth | POST | `/api/auth/login` | Bắt buộc |
| Auth | GET | `/api/auth/me` | Tùy chọn (refresh user) |
| Suppliers | GET | `/api/suppliers` | Query: search, status |
| Suppliers | POST | `/api/suppliers` | |
| Suppliers | PUT | `/api/suppliers/:id` | |
| Suppliers | DELETE | `/api/suppliers/:id` | |
| Categories | GET/POST/PUT/DELETE | `/api/categories` | |
| Products | GET | `/api/products` | Query: search, supplierId, categoryId, status |
| Products | POST/PUT/DELETE | `/api/products`, `:id` | |
| Stores | GET/POST/PUT/DELETE | `/api/stores` | |
| Users | GET/POST/PUT/DELETE | `/api/users` | |
| Orders | GET | `/api/orders` | Query: status, storeId, supplierId, dateFrom, dateTo |
| Orders | GET | `/api/orders/:id` | |
| Orders | POST | `/api/orders` | Tạo đơn (kèm orderSuppliers, orderItems) |
| Orders | PATCH | `/api/orders/:id/accept` | Admin |
| Orders | PATCH | `/api/orders/:id/reject` | Admin |
| Orders | PATCH | `/api/orders/:id/confirm-total` | Admin |
| OrderSupplier | PATCH | `/api/order-suppliers/:id/confirm-receive` | Store, multipart ảnh |
| Supplier orders | GET | `/api/supplier-orders` | Query: status, dateFrom, dateTo; theo supplierId user |
| Supplier orders | GET | `/api/supplier-orders/:id` | |
| Supplier orders | PATCH | `/api/supplier-orders/:id/status` | Body: { status } |
| Reports | GET | `/api/reports/summary` | Tùy chọn; query dateFrom, dateTo |
| Dashboard | GET | `/api/dashboard/stats` | Tùy chọn |

---

## 12. Cấu trúc dữ liệu tham chiếu (FE)

- **Supplier:** id, code, name, contact, email, address, status  
- **Category:** id, name, description  
- **Product:** id, code, name, supplierId, categoryId, unit, price, status  
- **Store:** id, code, name, address, phone, status  
- **User:** id, email, name, role, storeId, supplierId, status  
- **Order:** id, storeId, storeName, status, orderDate, expectedDeliveryDate (DB: OverallExpectedDate), totalAmount, totalItemCount, createdBy, createdDate, orderSuppliers[]  
- **OrderSupplier:** id, orderId, supplierId, supplierName, status, expectedDeliveryDate, actualDeliveryDate, confirmDate, note, totalAmount, taxAmount, paymentStatus, paidAmount, paidDate, receivedBy, receivedDate, receiveImages[], orderItems[]  
- **OrderItem:** id, productId, productName, quantity, unit, price, discountAmount, taxPercent, taxAmount  
- **ReceiveImage:** id, type ("received" | "invoice"), imageUrl, fileName  

Tất cả API (trừ login) nên yêu cầu header: `Authorization: Bearer <token>` và trả 401 khi hết phiên hoặc token không hợp lệ.
