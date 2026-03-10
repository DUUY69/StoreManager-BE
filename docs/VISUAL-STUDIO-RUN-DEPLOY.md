# Mở, chạy và Deploy BE trên Visual Studio

## 1. Mở project

1. Mở **Visual Studio** (2022 khuyến nghị).
2. **File** → **Open** → **Folder** (hoặc **Project/Solution**).
3. Chọn thư mục **`BE`** (chứa file `AdminDashboard.Api.csproj`).
4. Visual Studio nhận diện đây là .NET project và load solution.

**Hoặc:** **File** → **Open** → **Project/Solution** → chọn file **`AdminDashboard.Api.csproj`** trong thư mục BE.

---

## 2. Chạy (Run) – xem Swagger

1. Trong **Solution Explorer**, chuột phải vào project **AdminDashboard.Api** → **Set as Startup Project** (nếu có nhiều project).
2. Nhấn **F5** (Run with Debug) hoặc **Ctrl+F5** (Run without Debug).
3. Trình duyệt sẽ mở tự động (nếu đã bật trong **launchSettings.json**):
   - **http://localhost:5000/swagger** hoặc **https://localhost:5001/swagger**
4. Nếu không tự mở: vào trình duyệt, gõ **http://localhost:5000/swagger** (cổng in trong cửa sổ Output khi chạy).

**Đổi profile chạy (HTTP/HTTPS):**  
Trên thanh toolbar chọn dropdown bên cạnh nút Run (ví dụ **AdminDashboard.Api**, **http** hoặc **https**) rồi bấm Run.

---

## 3. Cấu hình trước khi chạy (tùy chọn)

- **Connection string:** Mở **appsettings.json** (hoặc **appsettings.Development.json**), sửa `ConnectionStrings:DefaultConnection` cho đúng SQL Server của bạn.
- **Cổng/URL:** Mở **Properties/launchSettings.json**, sửa `applicationUrl` nếu muốn đổi port (ví dụ 5050, 5002).

---

## 4. Deploy (phát hành)

### Cách 1: Publish ra thư mục (chạy bằng file exe hoặc host IIS)

1. Chuột phải vào project **AdminDashboard.Api** → **Publish**.
2. Chọn **Folder** → **Next**.
3. **Location:** chọn thư mục đích (ví dụ `C:\Publish\AdminDashboard.Api`) → **Finish**.
4. Trong trang Publish, bấm **Publish**.
5. Sau khi xong, trong thư mục đó có file **AdminDashboard.Api.exe** (hoặc `dotnet AdminDashboard.Api.dll` nếu chạy bằng `dotnet run`).

**Chạy sau khi publish (trên máy có .NET 8 Runtime):**

- Mở cmd tại thư mục publish, chạy:  
  `dotnet AdminDashboard.Api.dll`  
  hoặc chạy **AdminDashboard.Api.exe** (nếu đã chọn self-contained khi publish).

### Cách 2: Publish dạng Framework-dependent hoặc Self-contained

1. Chuột phải project → **Publish** → **Folder** → **Next**.
2. Bấm **Show all settings** (hoặc **Edit**).
3. **Configuration:** Release.
4. **Target Runtime:** 
   - **Portable (Framework-dependent):** cần cài .NET 8 Runtime trên máy đích.
   - **win-x64** (hoặc **linux-x64**): Self-contained, không cần cài Runtime.
5. **Save** → **Publish**.

### Cách 3: Deploy lên IIS (Windows Server)

1. Publish ra folder như Cách 1 (Target Runtime: **win-x64** hoặc **Portable**).
2. Trên server: **IIS Manager** → **Add Website** (hoặc Application trong Default Web Site).
3. **Physical path:** trỏ tới thư mục đã publish.
4. **Binding:** port (ví dụ 80, 443) và host name nếu cần.
5. **Application Pool:** chọn hoặc tạo pool, **.NET CLR version** = **No Managed Code** (vì đây là ASP.NET Core).
6. Đảm bảo đã cài **ASP.NET Core Hosting Bundle** trên server (nếu dùng Framework-dependent).

### Cách 4: Deploy lên Azure / cloud khác

- **Azure App Service:** Chuột phải project → **Publish** → chọn **Azure** → **Azure Web App (Windows/Linux)** → đăng nhập Azure, chọn hoặc tạo Web App → **Publish**.
- Các nền tảng khác (AWS, Docker, v.v.): thường dùng output **Publish folder** hoặc **Docker image** rồi deploy theo tài liệu của từng dịch vụ.

---

## 5. Lưu ý khi deploy

- **appsettings.json:** Trên production nên đổi ConnectionString, Jwt:Key (bí mật) qua **appsettings.Production.json** hoặc biến môi trường (User Secrets / Azure App Settings).
- **Swagger:** Trong **Program.cs** hiện đang bật Swagger cả môi trường không phải Development. Nếu không muốn lộ Swagger trên production, bọc `app.UseSwagger(); app.UseSwaggerUI(...)` trong `if (app.Environment.IsDevelopment()) { ... }` (hoặc điều kiện tương đương).
- **CORS:** Trong **Program.cs** đang cho phép `localhost:5173`, `localhost:3000`. Khi deploy, thêm origin của FE thật (ví dụ `https://yourdomain.com`) vào `WithOrigins(...)`.
