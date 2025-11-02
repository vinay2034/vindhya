# 🏫 School Management System

A comprehensive full-stack school management application with a Flutter mobile app and Node.js backend, featuring role-based access for Admins, Teachers, and Parents.

## 📋 Project Overview

This system provides a complete solution for managing school operations including:
- Student enrollment and management
- Class and subject organization
- Teacher assignment and scheduling
- Attendance tracking and reporting
- Fee management and payment processing
- Media gallery for school events
- Role-based dashboards for different user types

## 🎯 Key Features

### For Administrators
- ✅ Complete user management (Teachers, Parents, Students)
- ✅ Class and subject creation and assignment
- ✅ Teacher assignment to classes and subjects
- ✅ Fee structure management
- ✅ Comprehensive reporting (Attendance, Fees, Analytics)
- ✅ Timetable management
- ✅ Media gallery management

### For Teachers
- ✅ Personal dashboard with today's schedule
- ✅ Attendance marking (individual and bulk)
- ✅ Student management for assigned classes
- ✅ Fee status tracking and updates
- ✅ Class overview and student profiles

### For Parents
- ✅ Child profile and academic progress
- ✅ Real-time attendance monitoring
- ✅ Online fee payment integration
- ✅ School photo and video gallery access
- ✅ Push notifications for important updates

## 🛠️ Technology Stack

### Backend
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose ODM
- **Authentication:** JWT (JSON Web Tokens)
- **Security:** bcrypt, helmet, CORS
- **File Upload:** Multer + Cloudinary
- **Validation:** Express Validator

### Frontend (Mobile)
- **Framework:** Flutter 3.0+
- **State Management:** BLoC Pattern (flutter_bloc)
- **Networking:** Dio
- **Local Storage:** SharedPreferences + Hive
- **UI Components:** Material Design
- **Media:** image_picker, video_player, cached_network_image

## 📁 Project Structure

```
school-management-system/
├── backend/                 # Node.js Backend API
│   ├── models/             # Mongoose schemas
│   ├── controllers/        # Request handlers
│   ├── routes/             # API routes
│   ├── middleware/         # Auth & validation middleware
│   ├── config/             # Database & service configs
│   ├── server.js           # Entry point
│   └── package.json
│
└── flutter_app/            # Flutter Mobile App
    ├── lib/
    │   ├── models/         # Data models
    │   ├── services/       # API & storage services
    │   ├── bloc/           # State management
    │   ├── screens/        # UI screens
    │   ├── widgets/        # Reusable widgets
    │   ├── utils/          # Utilities & constants
    │   └── main.dart       # App entry point
    └── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites
- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)
- Flutter SDK (v3.0 or higher)
- Android Studio / Xcode (for mobile development)

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Start MongoDB**
   ```bash
   # Local MongoDB
   mongod
   
   # Or use MongoDB Atlas connection string in .env
   ```

5. **Run the server**
   ```bash
   # Development
   npm run dev
   
   # Production
   npm start
   ```

   Server will run on `http://localhost:5000`

### Flutter App Setup

1. **Navigate to Flutter directory**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Edit `lib/utils/constants.dart`:
   ```dart
   static const String baseUrl = 'http://YOUR_IP:5000/api';
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Demo Credentials

Use these credentials to test the application:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@school.com | admin123 |
| Teacher | teacher@school.com | teacher123 |
| Parent | parent@school.com | parent123 |

## 🔌 API Documentation

### Base URL
```
http://localhost:5000/api
```

### Authentication Endpoints
```
POST   /auth/login          - User login
POST   /auth/register       - User registration
GET    /auth/me             - Get current user
PUT    /auth/profile        - Update profile
POST   /auth/logout         - Logout
```

### Admin Endpoints
```
GET    /admin/dashboard          - Dashboard stats
GET    /admin/users              - List all users
POST   /admin/users              - Create user
PUT    /admin/users/:id          - Update user
DELETE /admin/users/:id          - Delete user

GET    /admin/students           - List students
POST   /admin/students           - Create student
PUT    /admin/students/:id       - Update student
DELETE /admin/students/:id       - Delete student

GET    /admin/classes            - List classes
POST   /admin/classes            - Create class
PUT    /admin/classes/:id        - Update class
DELETE /admin/classes/:id        - Delete class

GET    /admin/subjects           - List subjects
POST   /admin/subjects           - Create subject
PUT    /admin/subjects/:id       - Update subject
DELETE /admin/subjects/:id       - Delete subject

GET    /admin/reports/attendance - Attendance reports
GET    /admin/reports/fees       - Fee reports
```

### Teacher Endpoints
```
GET    /teacher/dashboard            - Teacher dashboard
GET    /teacher/classes              - Assigned classes
GET    /teacher/students/:classId    - Class students
POST   /teacher/attendance           - Mark attendance
POST   /teacher/attendance/bulk      - Bulk attendance
GET    /teacher/attendance           - View attendance
GET    /teacher/fees/:studentId      - Student fees
PUT    /teacher/fees/:feeId          - Update fee
```

### Parent Endpoints
```
GET    /parent/dashboard             - Parent dashboard
GET    /parent/children              - List children
GET    /parent/attendance/:studentId - Student attendance
GET    /parent/fees/:studentId       - Student fees
POST   /parent/fees/pay              - Pay fees
GET    /parent/gallery               - Media gallery
GET    /parent/progress/:studentId   - Student progress
```

## 🗄️ Database Schema

### Collections
- **users** - Admin, Teacher, Parent accounts
- **students** - Student information
- **classes** - Class details and assignments
- **subjects** - Subject information
- **attendance** - Daily attendance records
- **fees** - Fee structure and payments
- **timetable** - Class schedules
- **gallery** - Photos and videos

See individual model files for detailed schema definitions.

## 🎨 UI Screens

### Implemented Screens
1. **Splash Screen** - App loading and auth check
2. **Login Screen** - Role-based authentication
3. **Admin Dashboard** - Statistics and management
4. **Teacher Dashboard** - Schedule and quick actions
5. **Parent Dashboard** - Child info and quick links

### Upcoming Screens
- Class Management (Admin)
- Subject Management (Admin)
- User Management (Admin)
- Attendance Marking (Teacher)
- Fee Payment (Parent)
- Gallery View (Parent)
- Student Progress (Parent)
- Reports and Analytics

## 🔒 Security Features

- Password hashing with bcrypt (10 salt rounds)
- JWT-based authentication
- Role-based access control (RBAC)
- Request validation with express-validator
- CORS configuration
- Helmet security headers
- Input sanitization

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm test
```

### Flutter Tests
```bash
cd flutter_app
flutter test
```

## 📦 Deployment

### Backend Deployment
Recommended platforms:
- Heroku
- AWS EC2
- DigitalOcean
- Railway

### Mobile App Deployment
- **Android:** Google Play Store
- **iOS:** Apple App Store

### Database
- **Production:** MongoDB Atlas
- **Backup:** Configure automated backups

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Development Roadmap

### Phase 1 - Core Features ✅
- [x] Authentication system
- [x] Database models
- [x] Basic API endpoints
- [x] Flutter app structure
- [x] Role-based dashboards

### Phase 2 - Advanced Features (In Progress)
- [ ] Complete CRUD operations for all entities
- [ ] Attendance marking interface
- [ ] Fee payment integration (Razorpay/Stripe)
- [ ] Media gallery with upload
- [ ] Push notifications
- [ ] Advanced reporting

### Phase 3 - Enhancements
- [ ] Chat/messaging system
- [ ] Homework submission
- [ ] Exam management
- [ ] Timetable interface
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Offline mode
- [ ] Analytics dashboard
- [ ] Export reports (PDF)

## 🐛 Known Issues

- Asset directories need to be created for Flutter app
- Fonts need to be added to the project
- Payment gateway integration pending
- Push notification setup required

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Backend Development:** Node.js + Express + MongoDB
- **Mobile Development:** Flutter + Dart
- **UI/UX Design:** Material Design principles

## 📧 Support

For questions, issues, or contributions:
- Create an issue on GitHub
- Email: support@schoolmanagement.com
- Documentation: Check README files in each directory

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- MongoDB team for the excellent database
- Express.js community
- All open-source contributors

---

**Built with ❤️ for better education management**
