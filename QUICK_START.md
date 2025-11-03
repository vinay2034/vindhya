# 🚀 Quick Start Guide - Vindhya School Management

## Running the App on Your Phone

### ✅ One-Time Setup (Required First Time Only)

**1. Add Firewall Rule** (Run as Administrator)
```powershell
# Right-click PowerShell → "Run as Administrator"
# Then run:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\add-firewall-rule.ps1
```

This allows your phone to connect to your computer's backend server.

---

## 🎯 Three Ways to Start the App

### Option 1: Complete Automatic Startup (Recommended)
**Starts both backend and Flutter app automatically**

```powershell
.\start-complete-app.ps1
```

This script will:
- ✅ Auto-detect your current IP address
- ✅ Update the Flutter app configuration
- ✅ Start the backend server
- ✅ Launch the app on your phone

---

### Option 2: Backend Server Only
**Just start the backend server**

```powershell
.\start-backend-server.ps1
```

Then manually run Flutter:
```powershell
cd frontend
flutter run -d TCQOXGYTLF8HUC9T
```

---

### Option 3: Manual Startup

**Terminal 1 - Backend Server:**
```powershell
cd backend
node server.js
```

**Terminal 2 - Flutter App:**
```powershell
cd frontend
flutter run -d TCQOXGYTLF8HUC9T
```

---

## 📱 Test Login Credentials

| Role    | Email                  | Password   |
|---------|------------------------|------------|
| Admin   | admin@school.com       | admin123   |
| Teacher | teacher@school.com     | teacher123 |
| Parent  | parent@school.com      | parent123  |

---

## 🔧 Troubleshooting

### Problem: "Connection Timeout" Error

**Solution 1: Check Same WiFi Network**
- Make sure your phone and computer are on the SAME WiFi network
- Check WiFi name on both devices

**Solution 2: Test Backend Connectivity**
Open Chrome on your phone and visit:
```
http://YOUR_IP:5000/health
```
Replace `YOUR_IP` with your computer's IP address shown in the terminal.

**Solution 3: Add Firewall Rule**
Run `add-firewall-rule.ps1` as Administrator (see setup above)

**Solution 4: Check IP Address Changed**
If your IP changed, just run `start-complete-app.ps1` again - it will auto-update.

---

### Problem: "Phone Not Detected"

**Solution:**
1. Connect phone via USB cable
2. Enable USB debugging on phone:
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable USB Debugging
3. Allow USB debugging when prompted on phone
4. Run: `flutter devices` to verify

---

### Problem: Backend Server Won't Start

**Check if port 5000 is already in use:**
```powershell
Get-Process -Name node
Stop-Process -Name node -Force
```

Then restart the backend server.

---

## 📖 What Each Script Does

| Script | Purpose |
|--------|---------|
| `add-firewall-rule.ps1` | Adds Windows Firewall rule to allow port 5000 |
| `start-backend-server.ps1` | Auto-detects IP and starts backend server |
| `start-complete-app.ps1` | Complete startup (backend + Flutter app) |
| `CHECK_NETWORK.md` | Detailed network troubleshooting guide |

---

## 🌐 Works on Any Network!

The scripts automatically detect your current IP address, so the app will work:
- ✅ At home
- ✅ At school
- ✅ At office
- ✅ On any WiFi network

Just run `start-complete-app.ps1` whenever you change networks!

---

## 💡 Pro Tips

1. **Quick Restart:** Press `R` in Flutter terminal for hot restart
2. **Hot Reload:** Press `r` for hot reload (faster, preserves state)
3. **View Logs:** Flutter terminal shows all debug logs
4. **Backend Logs:** Backend window shows all API requests
5. **Keep Windows Open:** Don't close backend server window while using app

---

## 🆘 Still Having Issues?

1. Check `CHECK_NETWORK.md` for detailed troubleshooting
2. Make sure MongoDB Atlas IP whitelist includes your current IP
3. Restart your computer if firewall rule didn't apply
4. Try temporarily disabling Windows Firewall to test

---

## 📱 Publishing to Play Store

When ready to publish, see:
- `PUBLISH_PLAYSTORE.md` - Complete guide
- `DEPLOYMENT_GUIDE.md` - Backend deployment options

For production, you'll need to:
1. Deploy backend to a cloud service (Render, Railway, etc.)
2. Update API URL in constants.dart with production URL
3. Build release APK/AAB
4. Submit to Google Play Store
