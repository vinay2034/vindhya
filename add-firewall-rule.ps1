# Run this script as Administrator
# Right-click PowerShell and select "Run as Administrator"

Write-Host "Adding Windows Firewall Rule for Node.js Backend..." -ForegroundColor Cyan

try {
    # Remove existing rule if it exists
    Remove-NetFirewallRule -DisplayName "Node.js Backend Port 5000" -ErrorAction SilentlyContinue
    
    # Add new firewall rule
    New-NetFirewallRule -DisplayName "Node.js Backend Port 5000" `
                        -Direction Inbound `
                        -LocalPort 5000 `
                        -Protocol TCP `
                        -Action Allow `
                        -Profile Any `
                        -Enabled True
    
    Write-Host " Firewall rule added successfully!" -ForegroundColor Green
    Write-Host "Your backend server can now accept connections from your phone." -ForegroundColor Green
}
catch {
    Write-Host " Failed to add firewall rule. Make sure you're running as Administrator!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nTo run as Administrator:" -ForegroundColor Yellow
    Write-Host "1. Right-click PowerShell" -ForegroundColor Yellow
    Write-Host "2. Select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "3. Run this script again" -ForegroundColor Yellow
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
