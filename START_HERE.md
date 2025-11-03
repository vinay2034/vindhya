# ⚡ SIMPLE STARTUP GUIDE

## 🎯 Two Steps to Run Your App

### Step 1: Add Firewall Rule (ONLY ONCE - First Time)

1. Right-click on **PowerShell** icon
2. Select **"Run as Administrator"**
3. Run this command:
```powershell
cd d:\Vindhya
.\add-firewall-rule.ps1
```

✅ **Done!** You never need to do this again.

---

### Step 2: Start the App (Every Time)

**Double-click: `start-app.bat`**

That's it! The script will:
- ✅ Stop old servers
- ✅ Start backend server
- ✅ Launch app on your phone

---

## 📱 Login to the App

Once the app opens on your phone, use:

**Admin Account:**
- Email: `admin@school.com`
- Password: `admin123`

**Teacher Account:**
- Email: `teacher@school.com`  
- Password: `teacher123`

**Parent Account:**
- Email: `parent@school.com`
- Password: `parent123`

---

## ⚠️ Important Notes

1. **Same WiFi:** Your phone and computer MUST be on the same WiFi network
2. **USB Connected:** Keep your phone connected via USB while starting
3. **Don't Close:** Don't close the "Backend Server" window that pops up

---

## 🔧 If Login Shows "Connection Timeout"

### Quick Fix:

**On your phone, open Chrome browser and visit:**
```
http://192.168.31.75:5000/health
```
(Replace `192.168.31.75` with your computer's IP address)

**If it doesn't load:**
1. Make sure phone and computer are on SAME WiFi
2. Run `add-firewall-rule.ps1` as Administrator again
3. Check if backend server window is running

**If it DOES load (shows success message):**
- Your network is working!
- Just restart the Flutter app

---

## 🚀 Alternative: Manual Start

If the batch file doesn't work, start manually:

**Terminal 1 - Backend:**
```cmd
cd d:\Vindhya\backend
node server.js
```

**Terminal 2 - Flutter App:**
```cmd
cd d:\Vindhya\frontend
flutter run -d TCQOXGYTLF8HUC9T
```

---

## 💡 Pro Tips

- **Hot Reload:** Press `r` in Flutter terminal to reload without rebuilding
- **Hot Restart:** Press `R` to full restart the app
- **Quit App:** Press `q` to stop the app
- **View Logs:** All errors appear in the Flutter terminal

---

## 📖 More Help?

- **Detailed Guide:** See `QUICK_START.md`
- **Network Issues:** See `CHECK_NETWORK.md`
- **Publishing:** See `PUBLISH_PLAYSTORE.md`

---

## ✅ Current Configuration

- **Backend:** Node.js + Express + MongoDB Atlas
- **Frontend:** Flutter (Dart)
- **Theme Color:** #ba78fc (Purple)
- **API URL:** Auto-detected based on your WiFi
- **Database:** Cloud MongoDB (works from anywhere)

---

## 🌐 Works on Any Network!

The app automatically adapts to your network. If you move to a different WiFi:
1. Stop the app (press `q` in terminal)
2. Double-click `start-app.bat` again
3. Done! It will work on the new network

No need to change any code!
