import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../dependency_injection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final storageService = getIt<StorageService>();
    final isLoggedIn = await storageService.isLoggedIn();
    
    if (!mounted) return;
    
    if (isLoggedIn) {
      final role = await storageService.getUserRole();
      _navigateToRoleDashboard(role ?? 'parent');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigateToRoleDashboard(String role) {
    String route = '/parent';
    
    switch (role.toLowerCase()) {
      case 'admin':
        route = '/admin';
        break;
      case 'teacher':
        route = '/teacher';
        break;
      case 'parent':
        route = '/parent';
        break;
    }
    
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B4EFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.school,
                size: 80,
                color: Color(0xFF6B4EFF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'School Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your school effortlessly',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
