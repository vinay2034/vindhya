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
                        const Color(AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Teachers',
                        _totalTeachers.toString(),
                        Icons.school,
                        const Color(AppColors.secondary),
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
                        const Color(AppColors.success),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Subjects',
                        _totalSubjects.toString(),
                        Icons.book,
                        const Color(AppColors.warning),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Today's Attendance Card - Enhanced Design
                _buildEnhancedAttendanceCard(),
                
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
                  'Timetable Management',
                  'Create and manage class schedules',
                  Icons.schedule,
                  () {
                    Navigator.pushNamed(context, '/manage-timetable');
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
                
                _buildMenuCard(
                  'Fees Management',
                  'Track fees and payments',
                  Icons.payments,
                  () {
                    Navigator.pushNamed(context, '/fees-management');
                  },
                ),
                
                _buildMenuCard(
                  'Manage Teachers',
                  'View and manage teacher profiles',
                  Icons.people,
                  () {
                    Navigator.pushNamed(context, '/manage-teachers');
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
              ],
            ),
          ),
    );
  }

  Widget _buildEnhancedAttendanceCard() {
    // Calculate attendance percentage
    final attendancePercentage = _totalStudents > 0 
        ? ((_todayAttendance / _totalStudents) * 100).round() 
        : 0;
    
    // Get today's date
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateString = '${months[now.month - 1]} ${now.day}';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Color(0xFF4CAF50),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Today's Attendance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                Text(
                  dateString,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Progress Bar
            Stack(
              children: [
                // Background bar
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                // Progress bar
                FractionallySizedBox(
                  widthFactor: attendancePercentage / 100,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFF66BB6A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Overall percentage
                Row(
                  children: [
                    Text(
                      'Overall: ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$attendancePercentage%',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Present count
                Text(
                  '$_todayAttendance / $_totalStudents Present',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
          backgroundColor: const Color(AppColors.primary).withOpacity(0.1),
          child: Icon(icon, color: const Color(AppColors.primary)),
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
