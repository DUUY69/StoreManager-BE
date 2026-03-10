using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using AdminDashboard.Api.Data;

var builder = WebApplication.CreateBuilder(args);

// Render/Docker: lắng nghe cổng từ biến môi trường PORT
var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

// Nếu chưa có Azure SQL: để trống ConnectionStrings__DefaultConnection → dùng In-Memory (có sẵn user admin@cafe.vn / 123456)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (!string.IsNullOrWhiteSpace(connectionString))
    builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(connectionString));
else
    builder.Services.AddDbContext<AppDbContext>(options => options.UseInMemoryDatabase("AdminDashboard"));

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Admin Dashboard API",
        Version = "v1",
        Description = "API đặt hàng đa NCC - Liên kết FE theo API-FE-LIEN-KET.md"
    });
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        Description = "Nhập JWT trả về từ POST /api/auth/login. Ví dụ: Bearer {token}"
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
            },
            Array.Empty<string>()
        }
    });
});

var jwtKey = builder.Configuration["Jwt:Key"] ?? "DefaultKeyMin32CharactersLong!!";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "AdminDashboard.Api";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "AdminDashboard.Frontend";

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
        };
    });

// CORS: đọc từ config/env (Cors:Origins hoặc CORS__ORIGINS). VD: "https://your-app.vercel.app,https://your-app-*.vercel.app"
var corsOrigins = builder.Configuration["Cors:Origins"] ?? "";
var originsList = string.IsNullOrWhiteSpace(corsOrigins)
    ? new[] { "http://localhost:5173", "http://localhost:3000", "http://127.0.0.1:5173" }
    : corsOrigins.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.WithOrigins(originsList)
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Khi chạy In-Memory (chưa có Azure SQL): tạo DB và seed user admin để demo
if (string.IsNullOrWhiteSpace(connectionString))
{
    using (var scope = app.Services.CreateScope())
    {
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        db.Database.EnsureCreated();
        if (!db.Users.Any())
        {
            db.Users.Add(new User
            {
                Email = "admin@cafe.vn",
                Name = "Admin Cafe",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                Role = "Admin",
                Status = "Active",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            });
            db.SaveChanges();
        }
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Admin Dashboard API v1");
    });
}
else
{
    app.UseSwagger();
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "Admin Dashboard API v1"));
}

app.UseStaticFiles();
app.UseCors();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();
