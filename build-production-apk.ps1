# Complete Deployment and APK Build Script
# This script updates your app and builds production APK

param(
    [Parameter(Mandatory=$false)]
    [string]$RenderURL = ""
)

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "║       🚀 VINDHYA SCHOOL MANAGEMENT - APK BUILDER 🚀         ║" -ForegroundColor Cyan
Write-Host "║                                                              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check if Render URL is provided
if ($RenderURL -eq "") {
    Write-Host "📋 DEPLOYMENT STATUS CHECK" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "❓ Have you deployed to Render.com yet?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If YES - Run this script with your URL:" -ForegroundColor White
    Write-Host "   .\build-production-apk.ps1 -RenderURL 'https://your-url.onrender.com'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "If NO - Follow these steps first:" -ForegroundColor White
    Write-Host ""
    Write-Host "1️⃣  Go to https://render.com" -ForegroundColor White
    Write-Host "2️⃣  Sign in with GitHub" -ForegroundColor White
    Write-Host "3️⃣  Create New Web Service" -ForegroundColor White
    Write-Host "    - Repository: vinay2034/vindhya" -ForegroundColor Gray
    Write-Host "    - Root Directory: backend" -ForegroundColor Gray
    Write-Host "    - Build: npm install" -ForegroundColor Gray
    Write-Host "    - Start: node server.js" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4️⃣  Add Environment Variables:" -ForegroundColor White
    Write-Host "    MONGODB_URI = mongodb+srv://vinaykushwaha2050_db_user:Vin662034@cluster0.dli4wqx.mongodb.net/school_management" -ForegroundColor Gray
    Write-Host "    JWT_SECRET = school_management_jwt_secret_key_2024_change_this_in_production" -ForegroundColor Gray
    Write-Host "    JWT_EXPIRE = 7d" -ForegroundColor Gray
    Write-Host "    NODE_ENV = production" -ForegroundColor Gray
    Write-Host "    PORT = 5000" -ForegroundColor Gray
    Write-Host ""
    Write-Host "5️⃣  Go to https://cloud.mongodb.com" -ForegroundColor White
    Write-Host "    - Network Access → Add IP → 0.0.0.0/0" -ForegroundColor Gray
    Write-Host ""
    Write-Host "6️⃣  After deployment, copy your URL and run this script again!" -ForegroundColor White
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    exit 0
}

# Validate URL format
if (-not ($RenderURL -match "^https://.*\.onrender\.com$")) {
    Write-Host "❌ Error: Invalid URL format" -ForegroundColor Red
    Write-Host ""
    Write-Host "Expected format: https://your-app-name.onrender.com" -ForegroundColor Yellow
    Write-Host "Your input: $RenderURL" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Remove trailing slash
$RenderURL = $RenderURL.TrimEnd('/')

Write-Host "✅ Valid Render URL detected!" -ForegroundColor Green
Write-Host "   URL: $RenderURL" -ForegroundColor Cyan
Write-Host ""

# Step 1: Test Backend Connection
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🧪 STEP 1: Testing Backend Connection..." -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$RenderURL/health" -Method GET -TimeoutSec 15
    Write-Host "✅ Backend is online and responding!" -ForegroundColor Green
    Write-Host "   Status: $($response.status)" -ForegroundColor Gray
    Write-Host "   Message: $($response.message)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "⚠️  Backend not responding yet" -ForegroundColor Yellow
    Write-Host "   This is normal if deployment just finished" -ForegroundColor Gray
    Write-Host "   Wait 30 seconds and try again" -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Step 2: Update constants.dart
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📝 STEP 2: Updating Flutter App Configuration..." -ForegroundColor Cyan
Write-Host ""

$constantsFile = "d:\Vindhya\frontend\lib\utils\constants.dart"

if (-not (Test-Path $constantsFile)) {
    Write-Host "❌ Error: Cannot find constants.dart file" -ForegroundColor Red
    exit 1
}

# Read and update
$content = Get-Content $constantsFile -Raw
$oldPattern = "static const String baseUrl = 'http://[^']+'"
$newValue = "static const String baseUrl = '$RenderURL/api'"
$updatedContent = $content -replace $oldPattern, $newValue

# Save
$updatedContent | Set-Content $constantsFile -NoNewline

Write-Host "✅ Updated constants.dart" -ForegroundColor Green
Write-Host "   New API URL: $RenderURL/api" -ForegroundColor Cyan
Write-Host ""

# Step 3: Clean Flutter project
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🧹 STEP 3: Cleaning Flutter Build Cache..." -ForegroundColor Cyan
Write-Host ""

Push-Location "d:\Vindhya\frontend"

Write-Host "   Running flutter clean..." -ForegroundColor Gray
flutter clean | Out-Null

Write-Host "✅ Build cache cleaned" -ForegroundColor Green
Write-Host ""

# Step 4: Get dependencies
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "📦 STEP 4: Getting Flutter Dependencies..." -ForegroundColor Cyan
Write-Host ""

Write-Host "   Running flutter pub get..." -ForegroundColor Gray
flutter pub get | Out-Null

Write-Host "✅ Dependencies updated" -ForegroundColor Green
Write-Host ""

# Step 5: Build Release APK
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host "🔨 STEP 5: Building Production APK..." -ForegroundColor Cyan
Write-Host ""
Write-Host "   This may take 2-5 minutes..." -ForegroundColor Yellow
Write-Host ""

$buildOutput = flutter build apk --release 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ APK Built Successfully!" -ForegroundColor Green
    Write-Host ""
    
    $apkPath = "d:\Vindhya\frontend\build\app\outputs\flutter-apk\app-release.apk"
    
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host "🎉 SUCCESS! APK IS READY!" -ForegroundColor Green
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host ""
        Write-Host "📱 APK Location:" -ForegroundColor Cyan
        Write-Host "   $apkPath" -ForegroundColor White
        Write-Host ""
        Write-Host "📊 APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 WHAT'S NEXT:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1️⃣  Copy APK to your phone:" -ForegroundColor White
        Write-Host "    - Via USB" -ForegroundColor Gray
        Write-Host "    - Via WhatsApp" -ForegroundColor Gray
        Write-Host "    - Via Bluetooth" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2️⃣  Install on Android phone" -ForegroundColor White
        Write-Host "    - Enable 'Install from Unknown Sources'" -ForegroundColor Gray
        Write-Host "    - Tap APK file to install" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3️⃣  Test login credentials:" -ForegroundColor White
        Write-Host "    Admin:   admin@school.com / admin123" -ForegroundColor Gray
        Write-Host "    Teacher: teacher@school.com / teacher123" -ForegroundColor Gray
        Write-Host "    Parent:  parent@school.com / parent123" -ForegroundColor Gray
        Write-Host ""
        Write-Host "4️⃣  Share with others!" -ForegroundColor White
        Write-Host "    - App works from ANY network now" -ForegroundColor Gray
        Write-Host "    - WiFi, mobile data, anywhere in world" -ForegroundColor Gray
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host ""
        Write-Host "🎊 Your School Management App is Production Ready!" -ForegroundColor Green
        Write-Host ""
        
        # Open folder
        Write-Host "📂 Opening APK folder..." -ForegroundColor Cyan
        Start-Process "explorer.exe" -ArgumentList "/select,`"$apkPath`""
        
    } else {
        Write-Host "⚠️  APK file not found at expected location" -ForegroundColor Yellow
        Write-Host "   Check: d:\Vindhya\frontend\build\app\outputs\flutter-apk\" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ Build Failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build output:" -ForegroundColor Yellow
    Write-Host $buildOutput -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Common fixes:" -ForegroundColor Yellow
    Write-Host "   1. Run: flutter doctor" -ForegroundColor White
    Write-Host "   2. Check for syntax errors in Dart files" -ForegroundColor White
    Write-Host "   3. Try: flutter clean and flutter pub get" -ForegroundColor White
}

Pop-Location

Write-Host ""
Write-Host "Script completed at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
