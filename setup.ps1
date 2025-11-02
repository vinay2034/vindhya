# School Management System - Quick Setup Script
# This script helps set up the project quickly

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  School Management System - Setup Script" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command {
    param($Command)
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
Write-Host ""

$allPrerequisitesMet = $true

# Check Node.js
if (Test-Command "node") {
    $nodeVersion = node --version
    Write-Host "[✓] Node.js: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "[✗] Node.js not found. Please install from https://nodejs.org/" -ForegroundColor Red
    $allPrerequisitesMet = $false
}

# Check npm
if (Test-Command "npm") {
    $npmVersion = npm --version
    Write-Host "[✓] npm: v$npmVersion" -ForegroundColor Green
} else {
    Write-Host "[✗] npm not found" -ForegroundColor Red
    $allPrerequisitesMet = $false
}

# Check Flutter
if (Test-Command "flutter") {
    Write-Host "[✓] Flutter SDK installed" -ForegroundColor Green
} else {
    Write-Host "[✗] Flutter not found. Please install from https://flutter.dev/" -ForegroundColor Red
    $allPrerequisitesMet = $false
}

# Check MongoDB
if (Test-Command "mongod") {
    Write-Host "[✓] MongoDB installed" -ForegroundColor Green
} else {
    Write-Host "[!] MongoDB not found. You can:" -ForegroundColor Yellow
    Write-Host "    - Install locally: https://www.mongodb.com/try/download/community" -ForegroundColor Yellow
    Write-Host "    - Or use MongoDB Atlas: https://www.mongodb.com/cloud/atlas" -ForegroundColor Yellow
}

Write-Host ""

if (-not $allPrerequisitesMet) {
    Write-Host "Please install missing prerequisites and run this script again." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "All prerequisites met! Proceeding with setup..." -ForegroundColor Green
Write-Host ""

# Setup Backend
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Setting up Backend" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

Set-Location -Path "backend"

Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "[✓] Backend dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "[✗] Failed to install backend dependencies" -ForegroundColor Red
    Set-Location -Path ".."
    exit 1
}

# Create .env if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "[!] Please edit backend/.env with your configuration" -ForegroundColor Yellow
    Write-Host "    MongoDB URI, JWT secrets, etc." -ForegroundColor Yellow
}

Set-Location -Path ".."
Write-Host ""

# Setup Flutter App
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Setting up Flutter App" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

Set-Location -Path "flutter_app"

Write-Host "Installing Flutter dependencies..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -eq 0) {
    Write-Host "[✓] Flutter dependencies installed successfully" -ForegroundColor Green
} else {
    Write-Host "[✗] Failed to install Flutter dependencies" -ForegroundColor Red
    Set-Location -Path ".."
    exit 1
}

# Create asset directories
Write-Host "Creating asset directories..." -ForegroundColor Yellow

$directories = @(
    "assets",
    "assets/images",
    "assets/icons",
    "assets/animations",
    "assets/fonts"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Gray
    }
}

Write-Host "[✓] Asset directories created" -ForegroundColor Green

Set-Location -Path ".."
Write-Host ""

# Final instructions
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Configure Backend:" -ForegroundColor White
Write-Host "   - Edit backend/.env with your MongoDB URI and JWT secrets" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Start MongoDB:" -ForegroundColor White
Write-Host "   - Local: Run 'mongod' or start MongoDB service" -ForegroundColor Gray
Write-Host "   - Or use MongoDB Atlas cloud database" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Start Backend Server:" -ForegroundColor White
Write-Host "   cd backend" -ForegroundColor Gray
Write-Host "   npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Configure Flutter API URL:" -ForegroundColor White
Write-Host "   - Edit flutter_app/lib/utils/constants.dart" -ForegroundColor Gray
Write-Host "   - Set baseUrl to your backend URL" -ForegroundColor Gray
Write-Host "   - For Android Emulator: http://10.0.2.2:5000/api" -ForegroundColor Gray
Write-Host "   - For iOS Simulator: http://localhost:5000/api" -ForegroundColor Gray
Write-Host ""
Write-Host "5. Run Flutter App:" -ForegroundColor White
Write-Host "   cd flutter_app" -ForegroundColor Gray
Write-Host "   flutter run" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Login with demo credentials:" -ForegroundColor White
Write-Host "   Admin: admin@school.com / admin123" -ForegroundColor Gray
Write-Host "   (Create this user via API or MongoDB)" -ForegroundColor Gray
Write-Host ""

Write-Host "For detailed instructions, see SETUP_GUIDE.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
