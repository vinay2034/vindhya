# Test Teacher Login API
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Testing Teacher Login API" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$testCases = @(
    @{
        name = "Teacher Login - Amit Singh"
        email = "amit.singh@school.com"
        password = "teacher123"
    },
    @{
        name = "Admin Login"
        email = "admin@school.com"
        password = "admin123"
    }
)

foreach ($test in $testCases) {
    Write-Host "Test: $($test.name)" -ForegroundColor Yellow
    Write-Host "Email: $($test.email)" -ForegroundColor Gray
    
    $body = @{
        email = $test.email
        password = $test.password
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod `
            -Uri 'http://localhost:5000/api/auth/login' `
            -Method POST `
            -Body $body `
            -ContentType 'application/json' `
            -TimeoutSec 10
        
        Write-Host "✅ SUCCESS" -ForegroundColor Green
        Write-Host "User: $($response.user.name)" -ForegroundColor Green
        Write-Host "Role: $($response.user.role)" -ForegroundColor Green
        Write-Host "Email: $($response.user.email)" -ForegroundColor Green
        Write-Host "Token: $($response.token.Substring(0, 20))..." -ForegroundColor Green
        
    } catch {
        Write-Host "❌ FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            Write-Host "Response: $errorBody" -ForegroundColor Red
        }
    }
    
    Write-Host ""
}

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Test Complete" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
