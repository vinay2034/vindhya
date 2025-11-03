# Network Connection Troubleshooting Guide

## Current Setup

### Your Computer's IP Address
- **WiFi IP:** 192.168.31.75
- **Network:** Wi-Fi

### Backend Server
- **Running on:** http://192.168.31.75:5000
- **Also accessible at:** http://localhost:5000
- **Status:** ✅ Running (check with: `Get-Process -Name node`)

### Flutter App Configuration
- **API URL:** http://192.168.31.75:5000/api
- **File:** `frontend/lib/utils/constants.dart`

## ⚠️ IMPORTANT: Network Requirements

For your phone to connect to the backend server:

1. **Same WiFi Network**
   - Your phone MUST be connected to the SAME WiFi network as your computer
   - Current WiFi: Check your phone's WiFi settings
   - Computer WiFi: Wi-Fi network

2. **Windows Firewall**
   - Port 5000 must be open for incoming connections
   - The backend server needs to listen on 0.0.0.0 (all interfaces) ✅ Already configured

3. **Router Settings**
   - Some routers have "AP Isolation" which prevents devices from talking to each other
   - If login still fails, check your router settings

## Testing Steps

### Step 1: Verify Backend is Running
```powershell
Get-Process -Name node
```
You should see a node process running.

### Step 2: Test Backend from Computer
```powershell
Invoke-RestMethod -Uri "http://192.168.31.75:5000/health" -Method GET
```
If this fails, there's a firewall issue on your computer.

### Step 3: Test from Phone Browser
1. Open Chrome/Browser on your phone
2. Visit: `http://192.168.31.75:5000/health`
3. You should see: `{"status":"success","message":"Server is running"}`

If Step 3 fails:
- ❌ Phone and computer are NOT on the same WiFi
- ❌ Windows Firewall is blocking connections
- ❌ Router has AP Isolation enabled

### Step 4: Test Login from Phone Browser
1. Open: `http://192.168.31.75:5000/health` in phone browser
2. If it works, the Flutter app should also work

## Quick Fix Commands

### Restart Backend Server
```powershell
Stop-Process -Name node -Force
cd d:\Vindhya\backend
node server.js
```

### Check Current IP Address
```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq "Wi-Fi"}
```

### Add Firewall Rule (Run as Administrator)
```powershell
New-NetFirewallRule -DisplayName "Node.js Port 5000" -Direction Inbound -LocalPort 5000 -Protocol TCP -Action Allow
```

## Test Credentials

Once everything is working, use these credentials:

### Admin Login
- Email: `admin@school.com`
- Password: `admin123`

### Teacher Login
- Email: `teacher@school.com`
- Password: `teacher123`

### Parent Login
- Email: `parent@school.com`
- Password: `parent123`

## Common Issues

### Issue 1: IP Address Changed
**Symptom:** Login was working before, now showing connection timeout

**Solution:**
1. Get your current IP: `Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -eq "Wi-Fi"}`
2. Update `frontend/lib/utils/constants.dart` with new IP
3. Rebuild the Flutter app

### Issue 2: Connection Timeout After 30 Seconds
**Symptom:** App shows "connection timeout" error

**Causes:**
- Phone not on same WiFi as computer
- Windows Firewall blocking port 5000
- Backend server not running
- Wrong IP address in constants.dart

### Issue 3: Backend Crashes
**Symptom:** Node process exits immediately

**Solution:**
Check if MongoDB Atlas is accessible:
```powershell
cd d:\Vindhya\backend
node test-db-connection.js
```

## Success Indicators

✅ Backend shows: "🚀 Server running on port 5000"
✅ Backend shows: "✅ MongoDB Connected Successfully"
✅ Backend shows: "🌐 Accessible at: http://192.168.31.75:5000"
✅ Phone browser can open: http://192.168.31.75:5000/health
✅ Flutter app connects without timeout errors

## Need Help?

If login still doesn't work after following all steps:
1. Take a screenshot of the error in the app
2. Check if phone browser can access: http://192.168.31.75:5000/health
3. Verify both phone and computer show the same WiFi name
4. Try disabling Windows Firewall temporarily to test
