# Vindhya School Management - Backend Server Starter
# This script automatically detects your IP and starts the backend server

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Vindhya School Management System" -ForegroundColor Cyan
Write-Host "Backend Server Startup Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Get the current WiFi IP address
Write-Host "🔍 Detecting your IP address..." -ForegroundColor Yellow
$ipAddress = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {$_.InterfaceAlias -like "*Wi-Fi*" -or $_.InterfaceAlias -like "*Ethernet*"} | 
    Where-Object {$_.IPAddress -notlike "169.254.*"} |
    Select-Object -First 1 -ExpandProperty IPAddress

if (-not $ipAddress) {
    Write-Host "❌ Could not detect IP address. Using localhost..." -ForegroundColor Red
    $ipAddress = "localhost"
} else {
    Write-Host "✅ Detected IP: $ipAddress" -ForegroundColor Green
}

# Update constants.dart with the current IP
Write-Host ""
Write-Host "📝 Updating Flutter app configuration..." -ForegroundColor Yellow
$constantsFile = "d:\Vindhya\frontend\lib\utils\constants.dart"
$content = Get-Content $constantsFile -Raw
$newContent = $content -replace "static const String baseUrl = 'http://.*?:5000/api';", "static const String baseUrl = 'http://${ipAddress}:5000/api';"
$newContent | Set-Content $constantsFile -NoNewline
Write-Host "✅ Updated API URL to: http://${ipAddress}:5000/api" -ForegroundColor Green

# Display server information
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Server Information:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "📍 Local URL:   http://localhost:5000" -ForegroundColor White
Write-Host "📱 Network URL: http://${ipAddress}:5000" -ForegroundColor White
Write-Host "🗄️  Database:   MongoDB Atlas (Remote)" -ForegroundColor White
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Important Notes:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "1. Make sure your phone is on the same WiFi network" -ForegroundColor Yellow
Write-Host "2. To test from phone browser: http://${ipAddress}:5000/health" -ForegroundColor Yellow
Write-Host "3. If login fails, run add-firewall-rule.ps1 as Administrator" -ForegroundColor Yellow
Write-Host ""

# Check if Node.js is running
$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    Write-Host "⚠️  Node.js is already running. Stopping..." -ForegroundColor Yellow
    Stop-Process -Name node -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# Start the backend server
Write-Host ""
Write-Host "🚀 Starting backend server..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Set-Location "d:\Vindhya\backend"
node server.js
