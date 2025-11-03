# Update Flutter App with Production URL
# Run this script after getting your Render URL

param(
    [Parameter(Mandatory=$true)]
    [string]$RenderURL
)

Write-Host "🚀 Updating Flutter app with production URL..." -ForegroundColor Cyan
Write-Host ""

# Validate URL
if (-not ($RenderURL -match "^https://.*\.onrender\.com$")) {
    Write-Host "❌ Error: URL must be in format: https://your-app.onrender.com" -ForegroundColor Red
    Write-Host "Example: https://vindhya-backend.onrender.com" -ForegroundColor Yellow
    exit 1
}

# Remove trailing slash if present
$RenderURL = $RenderURL.TrimEnd('/')

Write-Host "✅ URL validated: $RenderURL" -ForegroundColor Green
Write-Host ""

# Path to constants file
$constantsFile = "d:\Vindhya\frontend\lib\utils\constants.dart"

if (-not (Test-Path $constantsFile)) {
    Write-Host "❌ Error: Cannot find constants.dart file" -ForegroundColor Red
    exit 1
}

# Read file content
$content = Get-Content $constantsFile -Raw

# Update the baseUrl
$oldPattern = "static const String baseUrl = 'http://[^']+'"
$newValue = "static const String baseUrl = '$RenderURL/api'"

$updatedContent = $content -replace $oldPattern, $newValue

# Write back to file
$updatedContent | Set-Content $constantsFile -NoNewline

Write-Host "✅ Updated constants.dart" -ForegroundColor Green
Write-Host "   Old: Local IP (192.168.31.75)" -ForegroundColor Gray
Write-Host "   New: $RenderURL/api" -ForegroundColor Green
Write-Host ""

# Test the URL
Write-Host "🧪 Testing backend connection..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$RenderURL/health" -Method GET -TimeoutSec 10
    Write-Host "✅ Backend is responding!" -ForegroundColor Green
    Write-Host "   Status: $($response.status)" -ForegroundColor Gray
    Write-Host "   Message: $($response.message)" -ForegroundColor Gray
    Write-Host ""
} catch {
    Write-Host "⚠️ Warning: Cannot connect to backend yet" -ForegroundColor Yellow
    Write-Host "   This is normal if deployment just finished (wait 30 seconds)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "📱 Ready to run app!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Connect your phone via USB" -ForegroundColor White
Write-Host "2. Enable USB debugging" -ForegroundColor White
Write-Host "3. Run: cd d:\Vindhya\frontend; flutter run" -ForegroundColor White
Write-Host ""
Write-Host "Or build APK:" -ForegroundColor Yellow
Write-Host "   cd d:\Vindhya\frontend; flutter build apk --release" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Configuration complete! Your app now works on ANY network!" -ForegroundColor Green
