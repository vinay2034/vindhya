import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';
import 'teacher_profile_screen.dart';
import 'students_list_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final ApiService _apiService = getIt<ApiService>();

  Map<String, dynamic>? _teacherData;
  List<Map<String, dynamic>> _todaySchedule = [];
  List<Map<String, dynamic>> _myClasses = [];
  int _totalStudents = 0;
  int _upcomingAssignments = 0;
  bool _isLoading = true;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Get teacher profile
      final profileResponse = await _apiService.get('/auth/me');
      final teacherData = profileResponse.data['data']['user'];

      // Get teacher's classes
      final classesResponse = await _apiService.get('/teacher/classes');
      final classes = List<Map<String, dynamic>>.from(classesResponse.data['data'] ?? []);

      // Mock today's schedule - in real app would come from timetable API
      final schedule = [
        {
          'subject': 'Physics',
          'grade': 'Grade 10B',
          'time': '09:00 - 10:00 AM',
          'icon': Icons.science_outlined,
        },
        {
          'subject': 'Mathematics',
          'grade': 'Grade 10A',
          'time': '10:00 - 11:00 AM',
          'icon': Icons.calculate_outlined,
        },
        {
          'subject': 'Lunch Break',
          'grade': '',
          'time': '11:00 - 12:00 PM',
          'icon': Icons.restaurant_outlined,
        },
      ];

      // Calculate total students
      int totalStudents = 124; // Mock data - would come from API

      setState(() {
        _teacherData = teacherData;
        _myClasses = classes;
        _todaySchedule = schedule;
        _totalStudents = totalStudents;
        _upcomingAssignments = 3; // Mock data
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  void _handleLogout() {
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
            onPressed: () async {
              // Clear any stored auth data
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SafeArea(
              child: Column(
                children: [
                  // Main content
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: RefreshIndicator(
                        onRefresh: _loadDashboardData,
                        child: ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            // Header with profile and notification
                            _buildHeader(),
                            const SizedBox(height: 24),
                            
                            // Good Morning greeting
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Today's Schedule Card
                            _buildScheduleCard(),
                            const SizedBox(height: 20),
                            
                            // Total Students Card
                            _buildStatCard(
                              'Total Students',
                              _totalStudents.toString(),
                              const Color(0xFFFFF8E1),
                              const Color(0xFFFFC107),
                            ),
                            const SizedBox(height: 16),
                            
                            // Upcoming Assignments Card
                            _buildStatCard(
                              'Upcoming Assignments',
                              _upcomingAssignments.toString(),
                              const Color(0xFFE3F2FD),
                              const Color(0xFF2196F3),
                            ),
                            const SizedBox(height: 24),
                            
                            // My Classes Section
                            const Text(
                              'My Classes',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildMyClassesList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to mark attendance - would be implemented
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mark Attendance feature coming soon!')),
          );
        },
        backgroundColor: const Color(0xFFBA78FC),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    final profile = _teacherData?['profile'] ?? {};
    final name = profile['name'] ?? 'Harrison';
    
    return Row(
      children: [
        // Profile Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300, width: 2),
            image: profile['avatar'] != null
                ? DecorationImage(
                    image: NetworkImage(profile['avatar']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: profile['avatar'] == null
              ? const Icon(Icons.person, size: 28, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 12),
        // Name and role
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mr. ${name.split(' ').first}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                'Teacher',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        // Notification bell
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {},
            color: Colors.black87,
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 8),
        // Logout button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.logout, size: 20),
            onPressed: _handleLogout,
            color: Colors.red.shade700,
            padding: EdgeInsets.zero,
            tooltip: 'Logout',
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBA78FC), Color(0xFF9D5FE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._todaySchedule.map((schedule) => _buildScheduleItem(schedule)),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> schedule) {
    final isLunch = schedule['subject'] == 'Lunch Break';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              schedule['icon'] as IconData,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule['subject'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (!isLunch)
                  Text(
                    schedule['grade'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            schedule['time'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyClassesList() {
    if (_myClasses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.class_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No classes assigned',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _myClasses.map((classData) {
        return _buildClassCard(classData);
      }).toList(),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classData) {
    final className = classData['className'] ?? 'Mathematics';
    final section = classData['section'] ?? 'A';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                className,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFBA78FC),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Grade $section',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFBA78FC),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
              onPressed: () {
                // Navigate to class details
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFBA78FC),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        currentIndex: _currentNavIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
          
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentsListScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TeacherProfileScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}
