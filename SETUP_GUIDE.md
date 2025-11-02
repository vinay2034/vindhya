# 🚀 Quick Start Guide - School Management System

## Step-by-Step Setup Instructions

Follow these steps to get the complete school management system running on your local machine.

---

## 📋 Prerequisites Checklist

Before you begin, ensure you have:

- [ ] **Node.js** (v14 or higher) - [Download](https://nodejs.org/)
- [ ] **MongoDB** (v4.4 or higher) - [Download](https://www.mongodb.com/try/download/community)
- [ ] **Flutter SDK** (v3.0 or higher) - [Install Guide](https://docs.flutter.dev/get-started/install)
- [ ] **Android Studio** or **VS Code** with Flutter extension
- [ ] **Git** (for cloning the repository)

---

## Part 1: Backend Setup (15 minutes)

### Step 1: Start MongoDB

**Option A: Local MongoDB**
```bash
# Start MongoDB service
# Windows
net start MongoDB

# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongod
```

**Option B: MongoDB Atlas (Cloud)**
1. Create a free account at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a cluster
3. Get your connection string

### Step 2: Setup Backend

```bash
# Navigate to backend directory
cd d:\Vindhya\backend

# Install dependencies
npm install

# Create environment file
copy .env.example .env

# Edit .env file with your settings
notepad .env
```

**Required .env Configuration:**
```env
PORT=5000
MONGODB_URI=mongodb://localhost:27017/school_management
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=7d
```

### Step 3: Create Initial Admin User

**Option A: Via API (After starting server)**
```bash
# Start the server first
npm run dev

# Then in another terminal, use curl or Postman
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@school.com",
    "password": "admin123",
    "role": "admin",
    "profile": {
      "name": "Super Admin",
      "phone": "+1234567890"
    }
  }'
```

**Option B: Directly in MongoDB**
```bash
# Open MongoDB shell
mongosh

# Switch to database
use school_management

# Create admin user (password: admin123)
db.users.insertOne({
  email: "admin@school.com",
  password: "$2a$10$YourHashedPasswordHere",
  role: "admin",
  profile: {
    name: "Super Admin",
    phone: "+1234567890"
  },
  isActive: true,
  createdAt: new Date()
})
```

### Step 4: Start Backend Server

```bash
# Development mode with auto-reload
npm run dev

# You should see:
# ✅ MongoDB Connected Successfully
# 🚀 Server running on port 5000
```

**Test the backend:**
```bash
# Health check
curl http://localhost:5000/health

# Expected response:
# {"status":"success","message":"Server is running"}
```

---

## Part 2: Flutter App Setup (20 minutes)

### Step 1: Verify Flutter Installation

```bash
# Check Flutter is installed
flutter --version

# Run Flutter doctor
flutter doctor

# Fix any issues shown
```

### Step 2: Install Flutter Dependencies

```bash
# Navigate to Flutter app directory
cd d:\Vindhya\flutter_app

# Get dependencies
flutter pub get
```

**If you see errors about missing packages:**
```bash
flutter clean
flutter pub get
```

### Step 3: Configure API Connection

Edit `lib/utils/constants.dart`:

```dart
class ApiConfig {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // For iOS Simulator
  // static const String baseUrl = 'http://localhost:5000/api';
  
  // For Physical Device (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.XXX:5000/api';
  
  // ... rest of the file
}
```

**To find your computer's IP:**
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig

# Look for IPv4 Address (e.g., 192.168.1.100)
```

### Step 4: Create Required Directories

```bash
# Create asset directories
mkdir assets
mkdir assets\images
mkdir assets\icons
mkdir assets\animations
mkdir assets\fonts
```

### Step 5: Run the Flutter App

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Or just run (will prompt for device selection)
flutter run
```

**First Launch Tips:**
- First build takes 5-10 minutes
- Subsequent builds are much faster
- Use hot reload (press 'r') for instant updates during development

---

## Part 3: Testing the Application

### Backend API Testing

**Using curl:**
```bash
# Test login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@school.com","password":"admin123"}'
```

**Using Postman:**
1. Import the API collection (if available)
2. Set base URL: `http://localhost:5000/api`
3. Test authentication endpoints

### Mobile App Testing

1. **Launch the app**
   - Should show splash screen for 2 seconds
   - Redirects to login screen

2. **Test Login**
   - Email: `admin@school.com`
   - Password: `admin123`
   - Should redirect to Admin Dashboard

3. **Test Different Roles**
   - Create teacher and parent accounts via Admin
   - Login with different roles
   - Verify role-specific dashboards

---

## 🎨 Optional: Add Custom Branding

### Add App Logo

1. Create or download a school logo (PNG, 512x512px)
2. Save to `flutter_app/assets/images/logo.png`
3. Update splash screen and login screen

### Add Custom Fonts (Optional)

1. Download Poppins font from [Google Fonts](https://fonts.google.com/specimen/Poppins)
2. Place font files in `flutter_app/assets/fonts/`
3. Files needed:
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`

---

## 🔧 Troubleshooting Common Issues

### Backend Issues

**MongoDB Connection Failed**
```
Solution: Ensure MongoDB is running
# Check MongoDB status
# Windows: Check Services
# macOS: brew services list
# Linux: systemctl status mongod
```

**Port 5000 Already in Use**
```
Solution: Change port in .env file
PORT=5001

Or kill the process using port 5000:
# Windows
netstat -ano | findstr :5000
taskkill /PID <process_id> /F

# macOS/Linux
lsof -ti:5000 | xargs kill -9
```

### Flutter Issues

**Gradle Build Failed (Android)**
```bash
# Solution: Clear cache and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**CocoaPods Issues (iOS)**
```bash
# Solution: Reinstall pods
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

**API Connection Failed in App**
```
Solutions:
1. Check backend server is running
2. Verify API URL in constants.dart
3. For Android emulator, use 10.0.2.2 instead of localhost
4. Check network permissions in AndroidManifest.xml
```

**Cannot Connect from Physical Device**
```
Solutions:
1. Ensure phone and computer are on same WiFi
2. Use computer's IP address in constants.dart
3. Disable any firewall blocking port 5000
4. On Windows: Allow through Windows Firewall
```

---

## 📱 Device-Specific URLs

| Device Type | API Base URL |
|-------------|--------------|
| Android Emulator | `http://10.0.2.2:5000/api` |
| iOS Simulator | `http://localhost:5000/api` |
| Physical Device (Same WiFi) | `http://YOUR_COMPUTER_IP:5000/api` |
| Remote Server | `https://your-domain.com/api` |

---

## ✅ Setup Verification Checklist

After setup, verify everything works:

- [ ] Backend server starts without errors
- [ ] MongoDB connection successful
- [ ] Can access health endpoint: `http://localhost:5000/health`
- [ ] Can login via API with curl/Postman
- [ ] Flutter app compiles and runs
- [ ] App connects to backend (no network errors)
- [ ] Can login via mobile app
- [ ] Dashboard loads with mock data
- [ ] Can navigate between screens

---

## 🎯 Next Steps After Setup

1. **Create Sample Data**
   - Add teacher users
   - Add parent users
   - Create students
   - Setup classes
   - Add subjects

2. **Test Core Features**
   - Admin: Create class and assign teacher
   - Teacher: Mark attendance
   - Parent: View attendance and fees

3. **Customize**
   - Update app name and branding
   - Configure payment gateway
   - Setup push notifications
   - Add school-specific data

4. **Deploy**
   - Deploy backend to production server
   - Setup MongoDB Atlas for production
   - Build and release mobile app

---

## 📚 Useful Commands Reference

### Backend Commands
```bash
npm install              # Install dependencies
npm run dev              # Start development server
npm start                # Start production server
npm test                 # Run tests (if configured)
```

### Flutter Commands
```bash
flutter pub get          # Install dependencies
flutter run              # Run app
flutter build apk        # Build Android APK
flutter build ios        # Build iOS app
flutter clean            # Clean build files
flutter doctor           # Check Flutter setup
```

### MongoDB Commands
```bash
mongosh                  # Open MongoDB shell
use school_management    # Switch to database
db.users.find()          # View all users
db.students.count()      # Count students
```

---

## 🆘 Getting Help

If you encounter issues:

1. **Check Documentation**
   - Backend: `backend/README.md`
   - Flutter: `flutter_app/README.md`
   - Main: `README.md`

2. **Common Issues**
   - Review troubleshooting section above
   - Check error logs carefully

3. **Community Support**
   - Create an issue on GitHub
   - Check existing issues for solutions

4. **Contact**
   - Email: support@schoolmanagement.com
   - Include error logs and system info

---

## 🎉 You're All Set!

Congratulations! Your school management system is now running.

**Quick Test Flow:**
1. Start backend: `npm run dev` (in backend folder)
2. Start app: `flutter run` (in flutter_app folder)
3. Login as admin: admin@school.com / admin123
4. Explore the dashboards and features!

**Happy Coding! 🚀**
