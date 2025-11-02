# School Management Mobile App - Flutter

A comprehensive school management mobile application built with Flutter, featuring role-based access for Admin, Teachers, and Parents.

## Features

### 🔐 Authentication
- Secure login system
- Role-based access control (Admin, Teacher, Parent)
- Session management with JWT tokens
- Auto-redirect based on user role

### 👨‍💼 Admin Features
- Dashboard with statistics
- User management (Teachers, Parents, Students)
- Class and subject management
- Teacher assignment
- Attendance and fee reports
- Comprehensive analytics

### 👩‍🏫 Teacher Features
- Personal dashboard
- Class and student management
- Attendance marking (individual and bulk)
- Fee status updates
- Today's schedule view
- Quick access to student information

### 👨‍👩‍👧‍👦 Parent Features
- Child profile overview
- Attendance monitoring with statistics
- Fee payment gateway integration
- Photo and video gallery
- Student progress tracking
- Quick links to important features

## Tech Stack

```yaml
State Management: flutter_bloc + equatable
Networking: dio + pretty_dio_logger
Local Storage: shared_preferences + hive
UI Components: 
  - cached_network_image
  - shimmer
  - pull_to_refresh
  - fl_chart (analytics)
Media: 
  - image_picker
  - video_player
  - photo_view
Utils:
  - intl (date formatting)
  - get_it (dependency injection)
  - logger
```

## Project Structure

```
lib/
├── models/              # Data models
│   ├── user_model.dart
│   ├── student_model.dart
│   ├── class_model.dart
│   ├── attendance_model.dart
│   └── fee_model.dart
├── services/            # API and storage services
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
├── bloc/                # State management (BLoC pattern)
│   ├── auth_bloc/
│   ├── user_bloc/
│   └── fee_bloc/
├── screens/             # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── splash_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   ├── class_management_screen.dart
│   │   └── teacher_management_screen.dart
│   ├── teacher/
│   │   ├── teacher_dashboard.dart
│   │   └── attendance_screen.dart
│   └── parent/
│       ├── parent_dashboard.dart
│       ├── fee_payment_screen.dart
│       └── gallery_screen.dart
├── widgets/             # Reusable widgets
│   ├── custom_app_bar.dart
│   ├── fee_card.dart
│   └── attendance_widget.dart
├── utils/               # Utilities
│   ├── constants.dart
│   └── validators.dart
├── dependency_injection.dart
└── main.dart
```

## Installation & Setup

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android/iOS emulator or physical device

### Setup Steps

1. **Clone the repository**
   ```bash
   cd flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Open `lib/utils/constants.dart` and update the base URL:
   ```dart
   static const String baseUrl = 'http://YOUR_API_URL:5000/api';
   // For local development:
   // Android Emulator: 'http://10.0.2.2:5000/api'
   // iOS Simulator: 'http://localhost:5000/api'
   // Physical Device: 'http://YOUR_COMPUTER_IP:5000/api'
   ```

4. **Run the app**
   ```bash
   # Check available devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device-id>
   
   # Or simply run
   flutter run
   ```

## API Configuration

The app connects to the Node.js backend. Make sure the backend is running before using the app.

### Default API Endpoints
```dart
Base URL: http://localhost:5000/api

Authentication:
  POST /auth/login
  POST /auth/register
  GET  /auth/me

Admin:
  GET  /admin/dashboard
  GET  /admin/users
  POST /admin/students
  GET  /admin/classes

Teacher:
  GET  /teacher/dashboard
  POST /teacher/attendance
  GET  /teacher/classes

Parent:
  GET  /parent/dashboard
  GET  /parent/fees/:studentId
  POST /parent/fees/pay
  GET  /parent/gallery
```

## Demo Credentials

Test the app with these demo accounts:

**Admin**
- Email: `admin@school.com`
- Password: `admin123`

**Teacher**
- Email: `teacher@school.com`
- Password: `teacher123`

**Parent**
- Email: `parent@school.com`
- Password: `parent123`

## Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release
```

## Screenshots

The app includes:
- 🎨 Modern, clean UI design matching the provided mockups
- 📱 Responsive layouts for all screen sizes
- 🌙 Dark mode support (optional)
- 🎭 Smooth animations and transitions
- 🔔 Push notifications (coming soon)

## Features in Detail

### Authentication Flow
1. Splash screen checks for existing session
2. Auto-redirects to role-specific dashboard or login
3. Secure token storage with SharedPreferences
4. Auto-logout on token expiration

### Admin Dashboard
- Real-time statistics
- User CRUD operations
- Class and subject management
- Report generation
- Teacher assignment interface

### Teacher Dashboard
- Today's schedule at a glance
- Quick attendance marking
- Bulk attendance feature
- Fee tracking interface
- Student information access

### Parent Dashboard
- Child profile card with photo
- Attendance percentage display
- Upcoming fee reminders
- Quick action buttons
- Photo/video gallery access
- Student progress charts

## Error Handling

The app includes comprehensive error handling:
- Network errors with user-friendly messages
- API error responses
- Validation errors on forms
- Offline mode detection
- Token expiration handling

## Performance Optimizations

- Image caching with `cached_network_image`
- Lazy loading for lists
- Efficient state management with BLoC
- Minimal rebuilds with proper state separation
- Background sync for offline data

## Testing

```bash
# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Integration tests
flutter drive --target=test_driver/app.dart
```

## Troubleshooting

### Common Issues

**API Connection Failed**
- Ensure backend server is running
- Check API base URL configuration
- For Android emulator, use `10.0.2.2` instead of `localhost`
- Check network permissions in AndroidManifest.xml

**Build Errors**
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

**Dependency Issues**
```bash
# Update dependencies
flutter pub upgrade
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Roadmap

- [ ] Push notifications
- [ ] Offline mode with local database
- [ ] Chat/messaging feature
- [ ] Homework submission
- [ ] Exam results module
- [ ] Timetable view
- [ ] Multi-language support
- [ ] Dark theme
- [ ] Biometric authentication

## License

MIT License

## Support

For issues and questions:
- Create an issue on GitHub
- Email: support@schoolapp.com

## Acknowledgments

- Flutter team for the amazing framework
- All contributors who helped build this project
- The education community for feedback and suggestions
