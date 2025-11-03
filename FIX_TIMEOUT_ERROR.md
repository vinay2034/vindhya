# ⚡ URGENT: Fix Connection Timeout Error

## 🚨 PROBLEM:
Your app shows "connection timeout" because it's trying to connect to:
  http://192.168.31.75:5000/api

This ONLY works when:
  ✅ Phone is on SAME WiFi as computer
  ✅ Computer is running
  ✅ Backend server is running

## ✅ SOLUTION 1: Quick Test (Same WiFi Only)

Make sure:
1. Phone is connected to SAME WiFi network as computer
2. Phone is NOT on mobile data
3. Backend is running (I've restarted it for you)

Then try logging in again.

## ✅ SOLUTION 2: Make It Work EVERYWHERE (Permanent)

Deploy to Render.com (takes 10 minutes):

### Step 1: Deploy Backend (5 min)
1. Go to https://render.com
2. Sign in with GitHub
3. New Web Service → vinay2034/vindhya
4. Configure:
   - Root Directory: backend
   - Build: npm install
   - Start: node server.js
5. Add environment variables:
   ```
   MONGODB_URI = mongodb+srv://vinaykushwaha2050_db_user:Vin662034@cluster0.dli4wqx.mongodb.net/school_management
   JWT_SECRET = school_management_jwt_secret_key_2024_change_this_in_production
   JWT_EXPIRE = 7d
   NODE_ENV = production
   PORT = 5000
   ```
6. Deploy!

### Step 2: Configure MongoDB
1. Go to https://cloud.mongodb.com
2. Network Access → Add IP → 0.0.0.0/0

### Step 3: Get Your URL
Copy your Render URL like:
  https://vindhya-backend.onrender.com

### Step 4: Build APK Automatically
Run this command with YOUR Render URL:
```powershell
.\build-apk.ps1 -RenderURL "https://YOUR-URL.onrender.com"
```

This will:
✅ Update app configuration
✅ Build production APK
✅ App will work from ANYWHERE

## 📱 After APK is built:
Install the new APK on your phone and it will work on:
  ✅ Any WiFi network
  ✅ Mobile data
  ✅ Anywhere in the world

## 🎯 Which solution do you want?

**Quick Test (Option 1):**
- Check phone is on WiFi: Settings → WiFi
- Make sure it's the SAME network as computer
- Try login again

**Permanent Fix (Option 2):**
- Deploy to Render (I'll help you)
- Build new APK
- Works everywhere forever

Tell me which option you prefer!
