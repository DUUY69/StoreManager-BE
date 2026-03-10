# Test API tạo đơn: Login (StoreUser) -> POST /api/orders
# Chạy khi BE đang chạy (dotnet run). Mật khẩu seed: 123456

$baseUrl = "https://localhost:5001"
if ($env:API_BASE_URL) { $baseUrl = $env:API_BASE_URL.TrimEnd("/") }

# Bỏ qua lỗi SSL certificate (localhost)
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCerts : ICertificatePolicy { public bool CheckValidationResult(ServicePoint s, X509Certificate c, WebRequest r, int p) { return true; } }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCerts
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

Write-Host "1. Login (StoreUser q1@cafe.vn / 123456)..." -ForegroundColor Cyan
$loginBody = @{ email = "q1@cafe.vn"; password = "123456" } | ConvertTo-Json
try {
    $loginResp = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -ErrorAction Stop
} catch {
    Write-Host "   Login FAIL: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.ErrorDetails.Message) { Write-Host "   $($_.ErrorDetails.Message)" -ForegroundColor Red }
    exit 1
}
$token = $loginResp.token
$user = $loginResp.user
Write-Host "   OK. User: $($user.name) (StoreId: $($user.storeId))" -ForegroundColor Green

Write-Host "`n2. POST /api/orders (tao don)..." -ForegroundColor Cyan
$orderBody = @{
    storeId = 1
    orderSuppliers = @(
        @{
            supplierId = 1
            orderItems = @(
                @{ productId = 1; productName = "Cà phê Arabica rang xay 1kg"; quantity = 2; unit = "túi"; price = 280000 }
            )
        }
    )
} | ConvertTo-Json -Depth 5
$headers = @{ Authorization = "Bearer $token"; "Content-Type" = "application/json" }
try {
    $createWeb = Invoke-WebRequest -Uri "$baseUrl/api/orders" -Method POST -Body $orderBody -Headers $headers -UseBasicParsing -ErrorAction Stop
    $createResp = $createWeb.Content | ConvertFrom-Json
    Write-Host "   OK. Don tao thanh cong. OrderId: $($createResp.id), Status: $($createResp.status)" -ForegroundColor Green
    Write-Host "   Response: $($createWeb.Content)" -ForegroundColor Gray
} catch {
    Write-Host "   CREATE ORDER FAIL: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $rs = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($rs)
        $reader.BaseStream.Position = 0
        $r = $reader.ReadToEnd(); $reader.Close()
        if ($r) { Write-Host "   Response body: $r" -ForegroundColor Yellow }
    }
    if ($_.ErrorDetails.Message) { Write-Host "   ErrorDetails: $($_.ErrorDetails.Message)" -ForegroundColor Yellow }
    exit 1
}
Write-Host "`nTest API tao don: THANH CONG." -ForegroundColor Green
