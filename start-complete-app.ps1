# Vindhya School Management - Complete Startup Script
# This script starts both backend server and Flutter app on your phone

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Vindhya School Management System" -ForegroundColor Cyan
Write-Host "Complete Startup Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Get the current WiFi IP address
Write-Host "🔍 Step 1: Detecting your IP address..." -ForegroundColor Yellow
$ipAddress = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*"} | 
    Where-Object {$_.IPAddress -notlike "169.254.*"} |
    Select-Object -First 1 -ExpandProperty IPAddress

if (-not $ipAddress) {
    Write-Host "❌ Could not detect IP address." -ForegroundColor Red
    Write-Host "Please connect to WiFi and try again." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Detected IP: $ipAddress" -ForegroundColor Green

# Update constants.dart
Write-Host ""
Write-Host "📝 Step 2: Updating Flutter app configuration..." -ForegroundColor Yellow
$constantsFile = "d:\Vindhya\frontend\lib\utils\constants.dart"
$content = Get-Content $constantsFile -Raw
$newContent = $content -replace "static const String baseUrl = 'http://.*?:5000/api';", "static const String baseUrl = 'http://${ipAddress}:5000/api';"
$newContent | Set-Content $constantsFile -NoNewline
Write-Host "✅ API URL updated to: http://${ipAddress}:5000/api" -ForegroundColor Green

# Check if device is connected
Write-Host ""
Write-Host "📱 Step 3: Checking for connected devices..." -ForegroundColor Yellow
Set-Location "d:\Vindhya\frontend"
$devices = flutter devices 2>&1 | Select-String "RMX3686"
if (-not $devices) {
    Write-Host "❌ Phone not detected. Please connect your phone via USB." -ForegroundColor Red
    Write-Host "   Make sure USB debugging is enabled." -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Phone detected: RMX3686" -ForegroundColor Green

# Stop existing Node.js processes
Write-Host ""
Write-Host "🧹 Step 4: Cleaning up old processes..." -ForegroundColor Yellow
Stop-Process -Name node -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Write-Host "✅ Cleanup complete" -ForegroundColor Green

# Display connection info
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Connection Information:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "📍 Computer IP: $ipAddress" -ForegroundColor White
Write-Host "📱 Test URL:    http://${ipAddress}:5000/health" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANT: Make sure your phone is connected to the same WiFi!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Test credentials:" -ForegroundColor Cyan
Write-Host "  Admin:   admin@school.com / admin123" -ForegroundColor White
Write-Host "  Teacher: teacher@school.com / teacher123" -ForegroundColor White
Write-Host "  Parent:  parent@school.com / parent123" -ForegroundColor White
Write-Host ""

# Start backend server in a new window
Write-Host "🚀 Step 5: Starting backend server..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Push-Location d:\Vindhya\backend; node server.js"
Start-Sleep -Seconds 5

# Verify backend is running
try {
    $health = Invoke-RestMethod -Uri "http://localhost:5000/health" -Method GET -TimeoutSec 3
    Write-Host "✅ Backend server is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend server failed to start" -ForegroundColor Red
    exit 1
}

# Start Flutter app
Write-Host ""
Write-Host "📱 Step 6: Starting Flutter app on your phone..." -ForegroundColor Green
Write-Host "This may take 1-2 minutes..." -ForegroundColor Gray
Write-Host ""

Push-Location d:\Vindhya\frontend
flutter run -d TCQOXGYTLF8HUC9T
