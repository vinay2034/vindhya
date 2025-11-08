import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'attendance_reports_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final ApiService _apiService;
  bool _isLoading = true;
  
  int _totalStudents = 0;
  int _totalTeachers = 0;
  int _activeClasses = 0;
  int _totalSubjects = 0;
  int _todayAttendance = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    final storageService = StorageService();
    await storageService.init();
    _apiService = ApiService(storageService);
    _loadDashboardData();
  }
  
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _apiService.getStudents(),
        _apiService.getUsers(role: 'teacher'),
        _apiService.getClasses(),
        _apiService.getSubjects(),
      ]);
      
      setState(() {
        _totalStudents = (results[0]['data']['students'] as List).length;
        _totalTeachers = (results[1]['data']['users'] as List).length;
        _activeClasses = (results[2]['data']['classes'] as List).length;
        _totalSubjects = (results[3]['data']['subjects'] as List).length;
        // For now, set today's attendance to a percentage of students
        _todayAttendance = (_totalStudents * 0.85).round(); // 85% attendance
        _isLoading = false;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dashboard updated: $_totalStudents students, $_totalTeachers teachers, $_activeClasses classes, $_totalSubjects subjects'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats Cards - Row 1
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Students',
                        _totalStudents.toString(),
                        Icons.people,
                        Color(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Teachers',
                        _totalTeachers.toString(),
                        Icons.school,
                        Color(AppColors.secondary),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Stats Cards - Row 2
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active Classes',
                        _activeClasses.toString(),
                        Icons.class_,
                        Color(AppColors.success),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Subjects',
                        _totalSubjects.toString(),
                        Icons.book,
                        Color(AppColors.warning),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Stats Cards - Row 3 (Today's Attendance)
                _buildStatCard(
                  'Today\'s Attendance',
                  '$_todayAttendance / $_totalStudents',
                  Icons.how_to_reg,
                  Color(AppColors.info),
                ),
                
                const SizedBox(height: 24),
                
                // Management Options
                const Text(
            'Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
                const SizedBox(height: 12),
                
                _buildMenuCard(
                  'Manage Classes',
                  'Create and manage classes',
                  Icons.class_,
                  () {
                    Navigator.pushNamed(context, '/manage-classes');
                  },
                ),
                
                _buildMenuCard(
                  'Manage Subjects',
                  'Add and organize subjects',
                  Icons.book,
                  () {
                    Navigator.pushNamed(context, '/manage-subjects');
                  },
                ),
                
                _buildMenuCard(
                  'Timetable Management',
                  'Create and manage class schedules',
                  Icons.schedule,
                  () {
                    Navigator.pushNamed(context, '/manage-timetable');
                  },
                ),
                
                _buildMenuCard(
                  'Teacher Assignments',
                  'Assign classes and subjects to teachers',
                  Icons.assignment_ind,
                  () {
                    Navigator.pushNamed(context, '/teacher-assignments');
                  },
                ),
                
                _buildMenuCard(
                  'Fees Management',
                  'Track fees and payments',
                  Icons.payments,
                  () {
                    Navigator.pushNamed(context, '/fees-management');
                  },
                ),
                
                _buildMenuCard(
                  'Manage Students',
                  'Student enrollment and details',
                  Icons.people,
                  () {
                    Navigator.pushNamed(context, '/manage-students');
                  },
                ),
                
                _buildMenuCard(
                  'Attendance Reports',
                  'View attendance statistics',
                  Icons.analytics,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttendanceReportsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(AppColors.primary).withOpacity(0.1),
          child: Icon(icon, color: Color(AppColors.primary)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
