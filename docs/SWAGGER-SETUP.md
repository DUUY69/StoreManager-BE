# Công cụ tạo API + Swagger nhanh, chuẩn

## 1. ASP.NET Core + Swashbuckle (khuyến nghị)

Tự động sinh **Swagger UI** và file **OpenAPI JSON** từ controller. Chỉ cần viết API, Swagger có sẵn.

### Bước nhanh

```bash
# Tạo project Web API (nếu chưa có)
dotnet new webapi -n AdminDashboard.Api -o .

# Thêm Swagger
dotnet add package Swashbuckle.AspNetCore
```

**Program.cs** (hoặc **Startup.cs**). Cần `using Microsoft.OpenApi.Models;`:

```csharp
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Admin Dashboard API", Version = "v1" });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        Description = "JWT Bearer token. Ví dụ: Bearer {token}"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        [new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" } }] = Array.Empty<string>()
    });
});

// ...

app.UseSwagger();
app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "Admin Dashboard API v1"));
```

- Chạy app → mở **https://localhost:5xxx/swagger** → có giao diện test API.
- File OpenAPI chuẩn: **https://localhost:5xxx/swagger/v1/swagger.json**.

---

## 2. Dùng file OpenAPI (Swagger) có sẵn

Trong thư mục **BE** (cùng cấp với `API-FE-LIEN-KET.md`) có file **openapi.yaml** (OpenAPI 3.0) mô tả toàn bộ API theo tài liệu đó. Dùng để:

| Công cụ | Cách dùng |
|--------|-----------|
| **Swagger Editor** (online) | https://editor.swagger.io → File → Import file `openapi.yaml` → xem/export JSON. |
| **Postman** | Import → Link/File → chọn `openapi.yaml` → sinh collection. |
| **NSwag** (CLI) | `nswag openapi2cscontroller -i openapi.yaml` → sinh C# controller. |
| **OpenAPI Generator** | Sinh server stub (Node, .NET, …) từ file spec. |

---

## 3. Các tool khác (sinh API/Swagger từ spec hoặc từ code)

| Tool | Mục đích |
|------|----------|
| **NSwag** | Từ OpenAPI/Swagger → sinh C# client hoặc controller; tích hợp trong .NET. |
| **Swashbuckle** | Từ .NET controller → sinh Swagger UI + OpenAPI JSON (đã nêu trên). |
| **OpenAPI Generator** (openapi-generator.tech) | Từ file OpenAPI → sinh server (ASP.NET Core, Express, …) hoặc client. |
| **Scaffold-DbContext** (EF Core) | Từ SQL Server → sinh DbContext + entities; bạn viết controller (và dùng Swashbuckle để có Swagger). |

---

## 4. Luồng gợi ý (nhanh + chuẩn)

1. **Tạo Web API** (.NET 6/7/8): `dotnet new webapi`.
2. **Thêm Swashbuckle** như mục 1 → có Swagger UI ngay.
3. **Thêm EF Core** (nếu dùng DB): scaffold từ database `AdminDashboard` (xem `Database/01_Schema.sql`).
4. **Viết controller** theo `API-FE-LIEN-KET.md` (hoặc dùng **openapi.yaml** + NSwag/OpenAPI Generator để sinh skeleton).
5. **Test** qua Swagger UI tại `/swagger`.

Kết quả: API chuẩn REST + tài liệu Swagger/OpenAPI tự động, FE có thể dùng `swagger.json` để generate client hoặc đọc tài liệu.
