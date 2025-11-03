# Network Diagnostic Tool
# This script helps diagnose why your phone cannot connect

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Network Connection Diagnostic" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Get computer's IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.InterfaceAlias -like "*Wi-Fi*" -and 
    $_.IPAddress -notlike "169.254.*" -and 
    $_.IPAddress -notlike "127.*"
}).IPAddress

Write-Host "1. Computer IP Address:" -ForegroundColor Yellow
Write-Host "   $ip" -ForegroundColor White
Write-Host ""

# Test localhost
Write-Host "2. Testing Backend on localhost..." -ForegroundColor Yellow
try {
    $localhost = Invoke-RestMethod -Uri "http://localhost:5000/health" -Method GET -TimeoutSec 5
    Write-Host "   ✅ Backend running on localhost" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend NOT running on localhost" -ForegroundColor Red
    Write-Host "   Action: Run 'node server.js' in backend folder" -ForegroundColor Yellow
}
Write-Host ""

# Test network IP
Write-Host "3. Testing Backend on network IP..." -ForegroundColor Yellow
try {
    $network = Invoke-RestMethod -Uri "http://${ip}:5000/health" -Method GET -TimeoutSec 5
    Write-Host "   ✅ Backend accessible on network IP" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend NOT accessible on network IP" -ForegroundColor Red
    Write-Host "   Problem: Firewall or network issue" -ForegroundColor Yellow
}
Write-Host ""

# Check firewall
Write-Host "4. Checking Firewall Rule..." -ForegroundColor Yellow
$firewallRule = Get-NetFirewallRule -DisplayName "Vindhya Backend Port 5000" -ErrorAction SilentlyContinue
if ($firewallRule -and $firewallRule.Enabled -eq $true) {
    Write-Host "   ✅ Firewall rule exists and enabled" -ForegroundColor Green
} else {
    Write-Host "   ❌ Firewall rule missing or disabled" -ForegroundColor Red
    Write-Host "   Action: Run add-firewall-rule.ps1" -ForegroundColor Yellow
}
Write-Host ""

# Check node process
Write-Host "5. Checking Node.js Process..." -ForegroundColor Yellow
$nodeProcess = Get-Process -Name node -ErrorAction SilentlyContinue
if ($nodeProcess) {
    Write-Host "   ✅ Node.js is running (PID: $($nodeProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "   ❌ Node.js is NOT running" -ForegroundColor Red
    Write-Host "   Action: Start backend server" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " DIAGNOSIS SUMMARY" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Overall diagnosis
if ($localhost -and $network -and $firewallRule -and $nodeProcess) {
    Write-Host "✅ EVERYTHING IS WORKING!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your backend is accessible at:" -ForegroundColor Cyan
    Write-Host "  http://${ip}:5000/api" -ForegroundColor White
    Write-Host ""
    Write-Host "If phone still can't connect:" -ForegroundColor Yellow
    Write-Host "  1. Check phone is on SAME WiFi network" -ForegroundColor White
    Write-Host "  2. Phone WiFi name should match your computer's WiFi" -ForegroundColor White
    Write-Host "  3. Phone should NOT be on mobile data" -ForegroundColor White
    Write-Host ""
    Write-Host "To check phone's network:" -ForegroundColor Yellow
    Write-Host "  Phone Settings → WiFi → Check network name" -ForegroundColor White
    Write-Host "  Phone Settings → WiFi → Tap network → Check IP" -ForegroundColor White
    Write-Host "  Phone IP should start with: 192.168.31.xxx" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "❌ ISSUES FOUND" -ForegroundColor Red
    Write-Host ""
    Write-Host "Quick Fix:" -ForegroundColor Yellow
    Write-Host "  1. Stop backend: Stop-Process -Name node -Force" -ForegroundColor White
    Write-Host "  2. Start backend: cd d:\Vindhya\backend; node server.js" -ForegroundColor White
    Write-Host "  3. Run this diagnostic again" -ForegroundColor White
    Write-Host ""
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " PERMANENT SOLUTION" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To make your app work from ANY network:" -ForegroundColor Yellow
Write-Host "  1. Deploy to Render.com (see DEPLOY_NOW.md)" -ForegroundColor White
Write-Host "  2. Build production APK with Render URL" -ForegroundColor White
Write-Host "  3. App will work everywhere (WiFi, mobile data, worldwide)" -ForegroundColor White
Write-Host ""
Write-Host "Command: .\build-apk.ps1 -RenderURL 'https://YOUR-URL.onrender.com'" -ForegroundColor Cyan
Write-Host ""
