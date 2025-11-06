import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'student_attendance_screen.dart';
import 'teacher_profile_screen.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherProfileScreen(),
                ),
              );
            },
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Card
          Card(
            color: Color(AppColors.primary),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good Morning,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'Mr. Harrison',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have 4 classes today',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Classes',
                  '4',
                  Icons.class_,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Students',
                  '124',
                  Icons.people,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildScheduleCard(
            'Physics - Grade 10B',
            '09:00 - 10:00 AM',
            'Room 301',
          ),
          
          _buildScheduleCard(
            'Mathematics - Grade 10A',
            '10:00 - 11:00 AM',
            'Room 205',
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionCard(
            'Take Attendance',
            'Mark today\'s attendance',
            Icons.check_circle_outline,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentAttendanceScreen(),
                ),
              );
            },
          ),
          
          _buildActionCard(
            'View Students',
            'Access student information',
            Icons.people_outline,
            () {},
          ),
          
          _buildActionCard(
            'Update Fees',
            'Update fee payment status',
            Icons.attach_money,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Color(AppColors.primary), size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Widget _buildScheduleCard(String title, String time, String room) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(AppColors.secondary).withOpacity(0.2),
          child: Icon(Icons.schedule, color: Color(AppColors.secondary)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$time • $room'),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('View'),
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(AppColors.primary).withOpacity(0.1),
          child: Icon(icon, color: Color(AppColors.primary)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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
