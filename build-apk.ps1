# Build Production APK for Vindhya School Management App
# Usage: .\build-apk.ps1 -RenderURL "https://your-url.onrender.com"

param(
    [Parameter(Mandatory=$false)]
    [string]$RenderURL = ""
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Vindhya School Management - APK Builder" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Render URL is provided
if ($RenderURL -eq "") {
    Write-Host "STATUS CHECK:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Have you deployed to Render.com yet?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "If YES - Run:" -ForegroundColor White
    Write-Host '  .\build-apk.ps1 -RenderURL "https://your-url.onrender.com"' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "If NO - Deploy first:" -ForegroundColor White
    Write-Host "  1. Go to https://render.com" -ForegroundColor Gray
    Write-Host "  2. Sign in with GitHub" -ForegroundColor Gray
    Write-Host "  3. New Web Service -> vinay2034/vindhya" -ForegroundColor Gray
    Write-Host "  4. Root Directory: backend" -ForegroundColor Gray
    Write-Host "  5. Build: npm install" -ForegroundColor Gray
    Write-Host "  6. Start: node server.js" -ForegroundColor Gray
    Write-Host "  7. Add environment variables (see DEPLOY_NOW.md)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Also configure MongoDB Atlas:" -ForegroundColor White
    Write-Host "  https://cloud.mongodb.com -> Network Access -> Add 0.0.0.0/0" -ForegroundColor Gray
    Write-Host ""
    exit 0
}

# Validate URL
$RenderURL = $RenderURL.TrimEnd('/')

if (-not ($RenderURL -match "^https://.*\.onrender\.com$")) {
    Write-Host "ERROR: Invalid URL format" -ForegroundColor Red
    Write-Host "Expected: https://your-app.onrender.com" -ForegroundColor Yellow
    exit 1
}

Write-Host "Valid URL: $RenderURL" -ForegroundColor Green
Write-Host ""

# Step 1: Test backend
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "STEP 1: Testing Backend..." -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-RestMethod -Uri "$RenderURL/health" -Method GET -TimeoutSec 15
    Write-Host "SUCCESS: Backend is online!" -ForegroundColor Green
    Write-Host "Status: $($response.status)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "WARNING: Backend not responding" -ForegroundColor Yellow
    Write-Host "Wait 30 seconds if just deployed" -ForegroundColor Gray
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Step 2: Update constants.dart
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "STEP 2: Updating App Configuration..." -ForegroundColor Cyan
Write-Host ""

$constantsFile = "d:\Vindhya\frontend\lib\utils\constants.dart"

if (-not (Test-Path $constantsFile)) {
    Write-Host "ERROR: Cannot find constants.dart" -ForegroundColor Red
    exit 1
}

$content = Get-Content $constantsFile -Raw
$oldPattern = "static const String baseUrl = 'http://[^']+'"
$newValue = "static const String baseUrl = '$RenderURL/api'"
$updatedContent = $content -replace $oldPattern, $newValue
$updatedContent | Set-Content $constantsFile -NoNewline

Write-Host "SUCCESS: Updated constants.dart" -ForegroundColor Green
Write-Host "New URL: $RenderURL/api" -ForegroundColor Cyan
Write-Host ""

# Step 3: Clean
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "STEP 3: Cleaning Build Cache..." -ForegroundColor Cyan
Write-Host ""

Push-Location "d:\Vindhya\frontend"
flutter clean | Out-Null
Write-Host "SUCCESS: Cache cleaned" -ForegroundColor Green
Write-Host ""

# Step 4: Get dependencies
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "STEP 4: Getting Dependencies..." -ForegroundColor Cyan
Write-Host ""

flutter pub get | Out-Null
Write-Host "SUCCESS: Dependencies updated" -ForegroundColor Green
Write-Host ""

# Step 5: Build APK
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "STEP 5: Building Production APK..." -ForegroundColor Cyan
Write-Host ""
Write-Host "This may take 2-5 minutes..." -ForegroundColor Yellow
Write-Host ""

flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host " SUCCESS! APK IS READY!" -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
    Write-Host ""
    
    $apkPath = "d:\Vindhya\frontend\build\app\outputs\flutter-apk\app-release.apk"
    
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        Write-Host "APK Location:" -ForegroundColor Cyan
        Write-Host "  $apkPath" -ForegroundColor White
        Write-Host ""
        Write-Host "APK Size: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "NEXT STEPS:" -ForegroundColor Yellow
        Write-Host "  1. Copy APK to phone (USB/WhatsApp/Bluetooth)" -ForegroundColor White
        Write-Host "  2. Install on Android phone" -ForegroundColor White
        Write-Host "  3. Test with login credentials:" -ForegroundColor White
        Write-Host "     Admin: admin@school.com / admin123" -ForegroundColor Gray
        Write-Host "     Teacher: teacher@school.com / teacher123" -ForegroundColor Gray
        Write-Host "     Parent: parent@school.com / parent123" -ForegroundColor Gray
        Write-Host ""
        Write-Host "App now works on ANY network!" -ForegroundColor Green
        Write-Host ""
        
        # Open folder
        Write-Host "Opening APK folder..." -ForegroundColor Cyan
        Start-Process "explorer.exe" -ArgumentList "/select,`"$apkPath`""
    }
} else {
    Write-Host ""
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    Write-Host "Try: flutter doctor" -ForegroundColor Yellow
}

Pop-Location
Write-Host ""
