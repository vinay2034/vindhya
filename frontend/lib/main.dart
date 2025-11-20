import 'package:flutter/material.dart';
import 'dependency_injection.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/manage_classes_screen.dart';
import 'screens/admin/manage_subjects_screen.dart';
import 'screens/admin/manage_students_screen.dart';
import 'screens/admin/manage_timetable_screen.dart';
import 'screens/admin/teacher_assignments_screen.dart';
import 'screens/admin/fees_management_screen.dart';
import 'screens/admin/fee_approvals_screen.dart';
import 'screens/admin/manage_teachers_screen.dart';
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/parent/parent_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await setupDependencyInjection();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(AppColors.primary),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppColors.primary),
          secondary: const Color(AppColors.secondary),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(AppColors.dark)),
          titleTextStyle: TextStyle(
            color: Color(AppColors.dark),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.primary),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(AppColors.light),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(AppColors.primary), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(AppColors.danger), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/teacher': (context) => const TeacherDashboard(),
        '/parent': (context) => const ParentDashboard(),
        '/manage-classes': (context) => const ManageClassesScreen(),
        '/manage-subjects': (context) => const ManageSubjectsScreen(),
        '/manage-students': (context) => const ManageStudentsScreen(),
        '/manage-timetable': (context) => const ManageTimetableScreen(),
        '/teacher-assignments': (context) => const TeacherAssignmentsScreen(),
        '/fees-management': (context) => const FeesManagementScreen(),
        '/fee-approvals': (context) => const FeeApprovalsScreen(),
        '/manage-teachers': (context) => const ManageTeachersScreen(),
      },
    );
  }
}
