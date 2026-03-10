# Tạo/cập nhật DB mẫu AdminDashboard (Schema + Seed)
# Yêu cầu: SQL Server đang chạy, sqlcmd có sẵn (hoặc chạy thủ công trong SSMS)
# Usage: .\scripts\Run-DatabaseSetup.ps1
#        .\scripts\Run-DatabaseSetup.ps1 -Server "LAPTOP-VFF6TJ4B\PRJ301SPRING2025"

param(
    [string]$Server = "LAPTOP-VFF6TJ4B\PRJ301SPRING2025"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dbDir = Join-Path (Split-Path -Parent $scriptDir) "Database"
$schemaPath = Join-Path $dbDir "01_Schema.sql"
$seedPath = Join-Path $dbDir "02_SeedData.sql"
$extPath = Join-Path $dbDir "03_Inventory_Extensions.sql"
$userProfilePath = Join-Path $dbDir "04_User_Profile_Add_Phone.sql"
$fixUnicodePath = Join-Path $dbDir "06_FixUnicode_AllTextColumns.sql"

if (-not (Test-Path $schemaPath)) {
    Write-Host "Not found: $schemaPath" -ForegroundColor Red
    exit 1
}

Write-Host "Database setup - Server: $Server" -ForegroundColor Cyan
Write-Host ""

# Kiểm tra sqlcmd
$sqlcmd = Get-Command sqlcmd -ErrorAction SilentlyContinue
if (-not $sqlcmd) {
    Write-Host "sqlcmd not found. Run scripts manually in SQL Server Management Studio:" -ForegroundColor Yellow
    Write-Host "  1. Open 01_Schema.sql  -> Execute (F5)" -ForegroundColor White
    Write-Host "  2. Open 02_SeedData.sql -> Execute (F5)" -ForegroundColor White
    Write-Host "  3. If DB already existed: run 03_Inventory_Extensions.sql" -ForegroundColor White
    exit 0
}

# 1. Schema
Write-Host "Running 01_Schema.sql ..." -ForegroundColor Yellow
& sqlcmd -S $Server -E -b -f 65001 -i $schemaPath
if ($LASTEXITCODE -ne 0) {
    Write-Host "01_Schema.sql failed (exit $LASTEXITCODE)" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "01_Schema.sql OK" -ForegroundColor Green

# 1.5 Fix Unicode (nếu DB cũ có VARCHAR)
if (Test-Path $fixUnicodePath) {
    Write-Host "Running 06_FixUnicode_AllTextColumns.sql (optional) ..." -ForegroundColor Yellow
    & sqlcmd -S $Server -E -f 65001 -i $fixUnicodePath 2>$null
    Write-Host "06_FixUnicode_AllTextColumns.sql done" -ForegroundColor Green
}

# 2. Seed
Write-Host "Running 02_SeedData.sql ..." -ForegroundColor Yellow
& sqlcmd -S $Server -E -b -f 65001 -i $seedPath
if ($LASTEXITCODE -ne 0) {
    Write-Host "02_SeedData.sql failed (exit $LASTEXITCODE)" -ForegroundColor Red
    exit $LASTEXITCODE
}
Write-Host "02_SeedData.sql OK" -ForegroundColor Green

# 3. Extensions (cho DB đã có sẵn - bỏ qua lỗi nếu đã có trigger/table)
Write-Host "Running 03_Inventory_Extensions.sql (optional) ..." -ForegroundColor Yellow
& sqlcmd -S $Server -E -f 65001 -i $extPath 2>$null
Write-Host "03_Inventory_Extensions.sql done" -ForegroundColor Green

# 4. User profile: thêm cột Phone vào Users (nếu DB cũ chưa có)
if (Test-Path $userProfilePath) {
    Write-Host "Running 04_User_Profile_Add_Phone.sql (optional) ..." -ForegroundColor Yellow
    & sqlcmd -S $Server -E -f 65001 -i $userProfilePath 2>$null
    Write-Host "04_User_Profile_Add_Phone.sql done" -ForegroundColor Green
}

Write-Host ""
Write-Host "Database setup completed. Login: admin@cafe.vn | password: 123456" -ForegroundColor Cyan
