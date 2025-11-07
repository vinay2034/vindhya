// API Configuration
class ApiConfig {
  // Base URL - Local development
  //static const String baseUrl = 'http://192.168.31.75:5000/api';
  
  // Production API on Render (uncomment for production)
  static const String baseUrl = 'https://vindhya-niketan.onrender.com/api';
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String logout = '/auth/logout';
  
  // Admin Endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String users = '/admin/users';
  static const String students = '/admin/students';
  static const String classes = '/admin/classes';
  static const String subjects = '/admin/subjects';
  static const String fees = '/admin/fees';
  static const String timetable = '/admin/timetable';
  static const String attendanceReport = '/admin/reports/attendance';
  static const String feeReport = '/admin/reports/fees';
  
  // Teacher Endpoints
  static const String teacherDashboard = '/teacher/dashboard';
  static const String teacherClasses = '/teacher/classes';
  static const String teacherStudents = '/teacher/students';
  static const String teacherAttendance = '/teacher/attendance';
  static const String teacherFees = '/teacher/fees';
  
  // Parent Endpoints
  static const String parentDashboard = '/parent/dashboard';
  static const String children = '/parent/children';
  static const String parentAttendance = '/parent/attendance';
  static const String parentFees = '/parent/fees';
  static const String feePayment = '/parent/fees/pay';
  static const String gallery = '/parent/gallery';
  static const String studentProgress = '/parent/progress';
  
  // Timeout Duration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

// Storage Keys
class StorageKeys {
  static const String token = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
}

// User Roles
enum UserRole {
  admin,
  teacher,
  parent;
  
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.parent:
        return 'parent';
    }
  }
  
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'parent':
        return UserRole.parent;
      default:
        return UserRole.parent;
    }
  }
}

// Attendance Status
enum AttendanceStatus {
  present,
  absent,
  halfDay,
  late;
  
  String get value {
    switch (this) {
      case AttendanceStatus.present:
        return 'present';
      case AttendanceStatus.absent:
        return 'absent';
      case AttendanceStatus.halfDay:
        return 'half-day';
      case AttendanceStatus.late:
        return 'late';
    }
  }
  
  static AttendanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'half-day':
        return AttendanceStatus.halfDay;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.present;
    }
  }
}

// Fee Status
enum FeeStatus {
  paid,
  pending,
  overdue,
  partial;
  
  String get value {
    switch (this) {
      case FeeStatus.paid:
        return 'paid';
      case FeeStatus.pending:
        return 'pending';
      case FeeStatus.overdue:
        return 'overdue';
      case FeeStatus.partial:
        return 'partial';
    }
  }
  
  static FeeStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return FeeStatus.paid;
      case 'pending':
        return FeeStatus.pending;
      case 'overdue':
        return FeeStatus.overdue;
      case 'partial':
        return FeeStatus.partial;
      default:
        return FeeStatus.pending;
    }
  }
}

// App Colors
class AppColors {
  static const primary = 0xFFBA78FC;
  static const secondary = 0xFF00D4AA;
  static const success = 0xFF28A745;
  static const danger = 0xFFDC3545;
  static const warning = 0xFFFFC107;
  static const info = 0xFF17A2B8;
  static const dark = 0xFF343A40;
  static const light = 0xFFF8F9FA;
}

// App Strings
class AppStrings {
  static const String appName = 'School Management';
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to your account';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String loginButton = 'Login';
  static const String forgotPassword = 'Forgot Password?';
  
  // Error Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordShort = 'Password must be at least 6 characters';
  static const String loginFailed = 'Login failed. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
}

// String extensions used across the app
extension StringExtensions on String {
  /// Capitalize the first letter and make the rest lowercase.
  /// Example: 'male' -> 'Male'
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
