# Admin Dashboard - Backend API

API .NET 8 cho hệ thống đặt hàng đa NCC. Tài liệu API: [API-FE-LIEN-KET.md](API-FE-LIEN-KET.md).

## Yêu cầu

- .NET 8 SDK
- SQL Server (cho DB AdminDashboard, xem thư mục `Database/`)

## Chạy nhanh

```bash
cd BE
dotnet restore
dotnet run
```

Mở trình duyệt:

- **Swagger UI:** https://localhost:5xxx/swagger (hoặc http://localhost:5xxx/swagger)
- **OpenAPI JSON:** https://localhost:5xxx/swagger/v1/swagger.json

Cổng mặc định thường là 5000 (http) hoặc 5001 (https); xem output khi chạy `dotnet run`.

## Cấu trúc

- `Controllers/` – API theo API-FE-LIEN-KET (Auth, Suppliers, Categories, Products, Stores, Users, Orders, OrderSuppliers, SupplierOrders, Reports, Dashboard)
- `Models/` – DTO request/response
- `Program.cs` – Cấu hình Swagger, JWT Bearer, CORS
- `appsettings.json` – ConnectionString (AdminDashboard), Jwt (Key, Issuer, Audience, ExpiryMinutes)

## Đăng nhập (demo)

- **POST /api/auth/login** với body `{ "email": "admin@cafe.vn", "password": "123456" }` → trả về `user` + `token`
- Gửi kèm header **Authorization: Bearer {token}** cho các API còn lại

## Kết nối database

1. Tạo database theo script trong `Database/01_Schema.sql` và `02_SeedData.sql`
2. Sửa `ConnectionStrings:DefaultConnection` trong `appsettings.json` cho đúng server của bạn
3. (Tùy chọn) Thêm DbContext + Entity và inject vào controller để đọc/ghi DB thật thay vì dữ liệu mẫu

## CORS

Mặc định cho phép origin: `http://localhost:5173`, `http://localhost:3000`, `http://127.0.0.1:5173`. Sửa trong `Program.cs` nếu FE chạy cổng khác.
