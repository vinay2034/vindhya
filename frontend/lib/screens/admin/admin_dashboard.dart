import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Students',
                  '1,245',
                  Icons.people,
                  Color(AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Teachers',
                  '82',
                  Icons.school,
                  Color(AppColors.secondary),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Classes',
                  '48',
                  Icons.class_,
                  Color(AppColors.success),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Subjects',
                  '24',
                  Icons.book,
                  Color(AppColors.warning),
                ),
              ),
            ],
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
            () {},
          ),
          
          _buildMenuCard(
            'Manage Subjects',
            'Add and organize subjects',
            Icons.book,
            () {},
          ),
          
          _buildMenuCard(
            'Manage Teachers',
            'Add and assign teachers',
            Icons.person,
            () {},
          ),
          
          _buildMenuCard(
            'Manage Students',
            'Student enrollment and details',
            Icons.people,
            () {},
          ),
          
          _buildMenuCard(
            'Attendance Reports',
            'View attendance statistics',
            Icons.analytics,
            () {},
          ),
          
          _buildMenuCard(
            'Fee Reports',
            'Track fee collection',
            Icons.attach_money,
            () {},
          ),
        ],
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
