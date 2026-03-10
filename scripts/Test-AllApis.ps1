# Test toàn bộ API - in ra kết quả từng API
# Usage: .\scripts\Test-AllApis.ps1

[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
$base = "https://localhost:5001/api"
$ErrorActionPreference = "Stop"
$passed = 0
$failed = 0

function Format-Response {
    param($obj, $maxLen = 200)
    if ($null -eq $obj) { return "(null)" }
    $json = $obj | ConvertTo-Json -Depth 4 -Compress
    if ($json.Length -gt $maxLen) { $json = $json.Substring(0, $maxLen) + "..." }
    return $json
}

function Test-Api {
    param($Name, $Method, $Uri, $Headers = $null, $Body = $null, $ContentType = "application/json")
    try {
        $params = @{ Uri = $Uri; Method = $Method }
        if ($Headers) { $params.Headers = $Headers }
        if ($Body) { $params.Body = $Body; $params.ContentType = $ContentType }
        $r = Invoke-RestMethod @params
        $script:passed++
        Write-Host "OK: $Name" -ForegroundColor Green
        if ($null -ne $r) {
            $json = $r | ConvertTo-Json -Depth 3 -Compress
            if ($json.Length -gt 400) { $json = $json.Substring(0, 400) + "..." }
            Write-Host "   -> $json"
        } else {
            Write-Host "   -> (empty/204)"
        }
        return $r
    } catch {
        $script:failed++
        Write-Host "FAIL: $Name" -ForegroundColor Red
        Write-Host "   -> $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "========== TEST ALL APIs (base: $base) ==========" -ForegroundColor Cyan
Write-Host ""

# 1. Login
Write-Host "--- 1. AUTH ---" -ForegroundColor Yellow
$loginBody = '{"email":"admin@cafe.vn","password":"123456"}'
try {
    $login = Invoke-RestMethod -Uri "$base/auth/login" -Method Post -Body $loginBody -ContentType "application/json"
    $token = $login.token
    $passed++
    Write-Host "OK: POST /api/auth/login" -ForegroundColor Green
    Write-Host "   -> user: id=$($login.user.id) email=$($login.user.email) role=$($login.user.role) | token length=$($token.Length)"
} catch {
    $failed++
    Write-Host "FAIL: POST /api/auth/login -> $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Is API running? Try: dotnet run (in BE folder)" -ForegroundColor Red
    exit 1
}
$h = @{ Authorization = "Bearer $token" }
Write-Host ""

# 2. Auth me
Write-Host "--- 2. AUTH ME ---" -ForegroundColor Yellow
Test-Api "GET /api/auth/me" Get "$base/auth/me" $h | Out-Null
Write-Host ""

# 3. Suppliers
Write-Host "--- 3. SUPPLIERS ---" -ForegroundColor Yellow
Test-Api "GET /api/suppliers" Get "$base/suppliers" $h | Out-Null
Test-Api "GET /api/suppliers/1" Get "$base/suppliers/1" $h | Out-Null
Test-Api "POST /api/suppliers" Post "$base/suppliers" $h '{"code":"NCC99","name":"Test NCC","contact":"","email":"","address":"","status":"Active"}' | Out-Null
Test-Api "PUT /api/suppliers/1" Put "$base/suppliers/1" $h '{"code":"NCC01","name":"Updated","contact":"","email":"","address":"","status":"Active"}' | Out-Null
Test-Api "DELETE /api/suppliers/999" Delete "$base/suppliers/999" $h | Out-Null
Write-Host ""

# 4. Categories
Write-Host "--- 4. CATEGORIES ---" -ForegroundColor Yellow
Test-Api "GET /api/categories" Get "$base/categories" $h | Out-Null
Test-Api "GET /api/categories/1" Get "$base/categories/1" $h | Out-Null
Test-Api "POST /api/categories" Post "$base/categories" $h '{"name":"Test Cat","description":"Test"}' | Out-Null
Test-Api "PUT /api/categories/1" Put "$base/categories/1" $h '{"name":"Category One","description":"Updated desc"}' | Out-Null
Test-Api "DELETE /api/categories/999" Delete "$base/categories/999" $h | Out-Null
Write-Host ""

# 5. Products
Write-Host "--- 5. PRODUCTS ---" -ForegroundColor Yellow
Test-Api "GET /api/products" Get "$base/products" $h | Out-Null
Test-Api "GET /api/products?status=Active" Get "$base/products?status=Active" $h | Out-Null
Test-Api "GET /api/products/1" Get "$base/products/1" $h | Out-Null
Test-Api "POST /api/products" Post "$base/products" $h '{"code":"SP99","name":"Product Test","supplierId":1,"categoryId":1,"unit":"cai","price":100000,"status":"Active"}' | Out-Null
Test-Api "PUT /api/products/1" Put "$base/products/1" $h '{"code":"CF001","name":"Updated Product","supplierId":1,"categoryId":1,"unit":"tui","price":280000,"status":"Active"}' | Out-Null
Test-Api "DELETE /api/products/999" Delete "$base/products/999" $h | Out-Null
Write-Host ""

# 6. Stores
Write-Host "--- 6. STORES ---" -ForegroundColor Yellow
Test-Api "GET /api/stores" Get "$base/stores" $h | Out-Null
Test-Api "GET /api/stores/1" Get "$base/stores/1" $h | Out-Null
Test-Api "POST /api/stores" Post "$base/stores" $h '{"code":"CF99","name":"Store Test","address":"","phone":"","status":"Active"}' | Out-Null
Test-Api "PUT /api/stores/1" Put "$base/stores/1" $h '{"code":"CF01","name":"Store One","address":"Addr","phone":"","status":"Active"}' | Out-Null
Test-Api "DELETE /api/stores/999" Delete "$base/stores/999" $h | Out-Null
Write-Host ""

# 7. Users
Write-Host "--- 7. USERS ---" -ForegroundColor Yellow
Test-Api "GET /api/users" Get "$base/users" $h | Out-Null
Test-Api "GET /api/users/1" Get "$base/users/1" $h | Out-Null
Test-Api "POST /api/users" Post "$base/users" $h '{"email":"new@test.vn","name":"New User","role":"StoreUser","storeId":1,"supplierId":null,"status":"Active"}' | Out-Null
Test-Api "PUT /api/users/1" Put "$base/users/1" $h '{"email":"admin@cafe.vn","name":"Admin Updated","role":"Admin","storeId":null,"supplierId":null,"status":"Active"}' | Out-Null
Test-Api "DELETE /api/users/999" Delete "$base/users/999" $h | Out-Null
Write-Host ""

# 8. Orders
Write-Host "--- 8. ORDERS ---" -ForegroundColor Yellow
Test-Api "GET /api/orders" Get "$base/orders" $h | Out-Null
Test-Api "GET /api/orders?status=Completed" Get "$base/orders?status=Completed" $h | Out-Null
Test-Api "GET /api/orders/1" Get "$base/orders/1" $h | Out-Null
$orderBody = '{"storeId":1,"expectedDeliveryDate":null,"orderSuppliers":[{"supplierId":1,"orderItems":[{"productId":1,"productName":"Ca phe","quantity":2,"unit":"tui","price":280000,"discountAmount":0,"taxPercent":0,"taxAmount":0}]}]}'
Test-Api "POST /api/orders" Post "$base/orders" $h $orderBody | Out-Null
Test-Api "PATCH /api/orders/1/accept" Patch "$base/orders/1/accept" $h | Out-Null
Test-Api "PATCH /api/orders/2/reject" Patch "$base/orders/2/reject" $h | Out-Null
Test-Api "PATCH /api/orders/1/confirm-total" Patch "$base/orders/1/confirm-total" $h | Out-Null
Write-Host ""

# 9. Order-suppliers & Nhập kho
Write-Host "--- 9. ORDER-SUPPLIERS (confirm receive + stock-in) ---" -ForegroundColor Yellow
Test-Api "PATCH /api/order-suppliers/1/confirm-receive" Patch "$base/order-suppliers/1/confirm-receive" $h | Out-Null
Test-Api "POST /api/order-suppliers/5/stock-in" Post "$base/order-suppliers/5/stock-in" $h | Out-Null
Write-Host ""

# 10. Warehouse (kho)
Write-Host "--- 10. WAREHOUSE ---" -ForegroundColor Yellow
Test-Api "GET /api/warehouse/stock" Get "$base/warehouse/stock" $h | Out-Null
Test-Api "GET /api/warehouse/stock?storeId=1" Get "$base/warehouse/stock?storeId=1" $h | Out-Null
Test-Api "GET /api/warehouse/transactions" Get "$base/warehouse/transactions" $h | Out-Null
Test-Api "GET /api/warehouse/transactions?storeId=1&dateFrom=2025-01-01" Get "$base/warehouse/transactions?storeId=1&dateFrom=2025-01-01" $h | Out-Null
Write-Host ""

# 11. Supplier-orders
Write-Host "--- 11. SUPPLIER-ORDERS ---" -ForegroundColor Yellow
Test-Api "GET /api/supplier-orders" Get "$base/supplier-orders" $h | Out-Null
Test-Api "GET /api/supplier-orders?status=Pending" Get "$base/supplier-orders?status=Pending" $h | Out-Null
Test-Api "GET /api/supplier-orders/1" Get "$base/supplier-orders/1" $h | Out-Null
Test-Api "PATCH /api/supplier-orders/1/status" Patch "$base/supplier-orders/1/status" $h '{"status":"Confirmed"}' | Out-Null
Test-Api "PATCH /api/supplier-orders/1/status (Partial+note)" Patch "$base/supplier-orders/1/status" $h '{"status":"Partial","note":"Thiếu 2 túi, giao bù tuần sau"}' | Out-Null
Write-Host ""

# 12. Reports
Write-Host "--- 12. REPORTS ---" -ForegroundColor Yellow
Test-Api "GET /api/reports/summary" Get "$base/reports/summary" $h | Out-Null
Test-Api "GET /api/reports/summary?dateFrom=2025-01-01&dateTo=2025-12-31" Get "$base/reports/summary?dateFrom=2025-01-01&dateTo=2025-12-31" $h | Out-Null
Write-Host ""

# 13. Dashboard
Write-Host "--- 13. DASHBOARD ---" -ForegroundColor Yellow
Test-Api "GET /api/dashboard/stats" Get "$base/dashboard/stats" $h | Out-Null
Test-Api "GET /api/dashboard/stats?dateFrom=2025-01-01" Get "$base/dashboard/stats?dateFrom=2025-01-01" $h | Out-Null
Write-Host ""
Write-Host "========== TOTAL: $passed passed, $failed failed ==========" -ForegroundColor Cyan
