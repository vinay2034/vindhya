# School Management System - FTP Deployment Script
# This script helps you upload the Flutter web app to your shared hosting

Write-Host "🚀 School Management System - Deployment" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Configuration
$ftpServer = "ftp://31.170.167.234"
$ftpUsername = "u839958024.kolaresewa.in"
$ftpPassword = "Vin@2034"
$remotePath = "/Vindhya"
$localBuildPath = ".\frontend\build\web"

Write-Host "📦 Checking build folder..." -ForegroundColor Yellow

if (!(Test-Path $localBuildPath)) {
    Write-Host "❌ Build folder not found!" -ForegroundColor Red
    Write-Host "Run this command first: cd frontend; flutter build web --release" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Build folder found!`n" -ForegroundColor Green

Write-Host "📋 FTP Deployment Options:`n" -ForegroundColor Cyan

Write-Host "Option 1: Manual Upload (Recommended)" -ForegroundColor Yellow
Write-Host "  1. Open FileZilla or WinSCP"
Write-Host "  2. Connect with these details:"
Write-Host "     Host: $ftpServer" -ForegroundColor White
Write-Host "     Username: $ftpUsername" -ForegroundColor White
Write-Host "     Password: ******** (provided)" -ForegroundColor White
Write-Host "     Port: 21" -ForegroundColor White
Write-Host "  3. Navigate to: $remotePath" -ForegroundColor White
Write-Host "  4. Upload all files from: $localBuildPath" -ForegroundColor White
Write-Host ""

Write-Host "Option 2: Using WinSCP Command Line" -ForegroundColor Yellow
Write-Host "  Run this command if WinSCP is installed:" -ForegroundColor Gray
Write-Host "  winscp.com /command `"open ftp://${ftpUsername}:${ftpPassword}@31.170.167.234`" `"lcd $localBuildPath`" `"cd $remotePath`" `"put *`" `"exit`"" -ForegroundColor Gray
Write-Host ""

Write-Host "Option 3: Download FileZilla" -ForegroundColor Yellow
Write-Host "  https://filezilla-project.org/download.php" -ForegroundColor Cyan
Write-Host ""

Write-Host "📁 Files to Upload (from $localBuildPath):" -ForegroundColor Cyan
Get-ChildItem $localBuildPath -Recurse | Select-Object -First 10 | ForEach-Object {
    Write-Host "   - $($_.Name)" -ForegroundColor Gray
}
Write-Host "   ... and more`n" -ForegroundColor Gray

Write-Host "🌐 After Upload:" -ForegroundColor Green
Write-Host "   Your app will be available at: http://vindhya.kolaresewa.in" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  IMPORTANT: Backend Setup Required!" -ForegroundColor Red
Write-Host "   Your frontend needs a backend server." -ForegroundColor Yellow
Write-Host "   Current backend URL: $((Get-Content .\frontend\lib\utils\constants.dart | Select-String 'baseUrl').ToString().Trim())" -ForegroundColor Gray
Write-Host ""
Write-Host "   📖 See DEPLOYMENT_GUIDE.md for backend deployment options" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "Do you want to open FileZilla download page? (Y/N)"
if ($choice -eq 'Y' -or $choice -eq 'y') {
    Start-Process "https://filezilla-project.org/download.php"
}

Write-Host "`n✨ Deployment preparation complete!" -ForegroundColor Green
