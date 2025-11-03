# Deployment Guide for vindhya.kolaresewa.in

## 🚀 Deployment Strategy

### Current Setup:
- **Domain**: vindhya.kolaresewa.in
- **Hosting Type**: Shared hosting with FTP
- **FTP Server**: 31.170.167.234
- **Upload Path**: /home/u839958024/domains/kolaresewa.in/public_html/Vindhya

### ⚠️ Important Limitations:

**Shared FTP hosting typically supports:**
✅ Static HTML/CSS/JS files
✅ PHP applications
✅ Static file hosting

**Does NOT typically support:**
❌ Node.js backend (requires Node.js runtime)
❌ Long-running server processes
❌ Custom ports (like :5000)

---

## 📋 Recommended Deployment Options

### Option 1: Deploy Flutter Web Only (Recommended for Shared Hosting)

Deploy only the frontend to your shared hosting and use a separate backend hosting.

**Frontend**: vindhya.kolaresewa.in (your shared hosting)
**Backend**: Deploy to Heroku, Railway, Render, or DigitalOcean

### Option 2: Full Stack Deployment (Requires VPS/Cloud)

Deploy both frontend and backend together on a VPS or cloud platform.

**Platforms**: DigitalOcean, AWS, Heroku, Railway, Render

---

## 🎯 OPTION 1: Deploy Frontend to Your Hosting (RECOMMENDED)

### Step 1: Build Flutter Web App

```bash
cd frontend
flutter build web --release
```

This creates optimized files in `frontend/build/web/`

### Step 2: Upload to FTP

Files to upload from `frontend/build/web/`:
- index.html
- main.dart.js
- flutter.js
- assets/
- icons/
- All other files in build/web/

Upload to: `/home/u839958024/domains/kolaresewa.in/public_html/Vindhya/`

### Step 3: Update API Configuration

Before building, update the API URL in `frontend/lib/utils/constants.dart`:

```dart
// Point to your backend (deploy backend separately)
static const String baseUrl = 'https://your-backend-url.herokuapp.com/api';
```

### Backend Deployment Options:

#### A. Heroku (Free tier available)
1. Create Heroku account
2. Install Heroku CLI
3. Deploy backend to Heroku
4. Use Heroku URL in Flutter app

#### B. Railway (Free tier)
1. Connect GitHub repo
2. Deploy backend automatically
3. Get Railway URL

#### C. Render (Free tier)
1. Connect GitHub repo
2. Auto-deploy on push
3. Get Render URL

---

## 🎯 OPTION 2: Full VPS Deployment

### Recommended VPS Providers:

1. **DigitalOcean** ($6/month)
2. **Linode** ($5/month)
3. **Vultr** ($5/month)
4. **AWS Lightsail** ($5/month)

### Deployment Steps:

1. Get VPS with Ubuntu
2. Install Node.js, MongoDB, Nginx
3. Deploy backend
4. Build and serve Flutter web
5. Configure domain vindhya.kolaresewa.in

---

## 📦 Quick Deploy Scripts

### Deploy Frontend to FTP (Windows)

Create `deploy-frontend.ps1`:

```powershell
# Build Flutter web
cd frontend
flutter build web --release

# Upload to FTP (requires WinSCP or FileZilla)
Write-Host "Build complete! Upload 'frontend/build/web/' to FTP"
Write-Host "FTP: ftp://31.170.167.234"
Write-Host "Path: /home/u839958024/domains/kolaresewa.in/public_html/Vindhya/"
```

### Deploy Backend to Heroku

Create `deploy-backend-heroku.sh`:

```bash
cd backend
heroku login
heroku create vindhya-school-backend
git push heroku main
heroku open
```

---

## 🔧 Immediate Action Plan

### What I'll Do Now:

1. ✅ Build Flutter web app for production
2. ✅ Create FTP upload script
3. ✅ Prepare backend for cloud deployment
4. ✅ Update API configuration

### What You Need to Choose:

**For Backend, choose ONE:**
- [ ] Deploy to Heroku (free, recommended)
- [ ] Deploy to Railway (free, recommended)
- [ ] Deploy to Render (free)
- [ ] Get VPS hosting ($5-6/month)

Let me know which option you prefer, and I'll help you deploy!

---

## 💡 My Recommendation

**Best Solution for Your Setup:**

1. **Frontend**: Deploy to vindhya.kolaresewa.in (your shared hosting) ✅
2. **Backend**: Deploy to Railway or Render (free tier) ✅
3. **Database**: Already using MongoDB Atlas (cloud) ✅

This gives you:
- ✅ Free hosting for backend
- ✅ Use your domain for frontend
- ✅ Professional setup
- ✅ Easy to maintain

Shall I proceed with this approach?
