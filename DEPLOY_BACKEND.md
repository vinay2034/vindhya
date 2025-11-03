# Quick Backend Deployment Guide

## 🚀 Deploy Backend to Render (Recommended - Free Tier)

### Step 1: Sign Up
1. Go to https://render.com/
2. Sign up with GitHub

### Step 2: Create Web Service
1. Click "New +" → "Web Service"
2. Connect your GitHub repository: `vinay2034/vindhya`
3. Configure:
   - **Name**: vindhya-school-backend
   - **Root Directory**: backend
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free

### Step 3: Add Environment Variables
Click "Advanced" → "Add Environment Variable":

```
NODE_ENV=production
PORT=10000
MONGODB_URI=mongodb+srv://vinaykushwaha2050_db_user:Vin662034@cluster0.dli4wqx.mongodb.net/school_management?retryWrites=true&w=majority
JWT_SECRET=school_management_jwt_secret_key_2024_change_this_in_production
JWT_EXPIRE=7d
JWT_REFRESH_SECRET=school_management_refresh_token_secret_2024
JWT_REFRESH_EXPIRE=30d
```

### Step 4: Deploy
1. Click "Create Web Service"
2. Wait 2-5 minutes for deployment
3. Copy your backend URL (e.g., `https://vindhya-school-backend.onrender.com`)

### Step 5: Update Flutter App
Update `frontend/lib/utils/constants.dart`:
```dart
static const String baseUrl = 'https://vindhya-school-backend.onrender.com/api';
```

Then rebuild:
```bash
cd frontend
flutter build web --release
```

Upload new build to FTP!

---

## 🚀 Alternative: Deploy to Railway

### Step 1: Sign Up
1. Go to https://railway.app/
2. Sign in with GitHub

### Step 2: New Project
1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose `vinay2034/vindhya`
4. Select "backend" folder

### Step 3: Add Variables
Add same environment variables as above

### Step 4: Deploy
Railway auto-deploys and gives you a URL!

---

## 🚀 Alternative: Deploy to Heroku

### Prerequisites
```bash
# Install Heroku CLI
# Windows: Download from https://devcenter.heroku.com/articles/heroku-cli
```

### Commands
```bash
cd backend
heroku login
heroku create vindhya-school-backend
heroku config:set MONGODB_URI="mongodb+srv://vinaykushwaha2050_db_user:Vin662034@cluster0.dli4wqx.mongodb.net/school_management"
heroku config:set JWT_SECRET="school_management_jwt_secret_key_2024"
heroku config:set JWT_REFRESH_SECRET="school_management_refresh_token_secret_2024"
heroku config:set NODE_ENV=production
git push heroku main
```

Your backend URL: `https://vindhya-school-backend.herokuapp.com`

---

## ✅ After Backend is Deployed

1. Get your backend URL
2. Update Flutter constants
3. Rebuild Flutter web
4. Upload to FTP
5. Test at vindhya.kolaresewa.in

Done! 🎉
