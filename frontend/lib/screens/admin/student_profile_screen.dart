import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StudentProfileScreen extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentProfileScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Navigate to edit screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(AppColors.primary).withOpacity(0.1),
              ),
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(AppColors.primary),
                    child: Text(
                      _getInitials(student['name'] ?? 'Student'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Student Name
                  Text(
                    student['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Class and Roll Number
                  Text(
                    '${student['classId']?['className'] ?? 'N/A'}, ${student['classId']?['section'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Roll No: ${student['rollNumber'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.message_outlined,
                        label: 'Message',
                        color: Color(AppColors.primary),
                        onTap: () {},
                      ),
                      _buildActionButton(
                        icon: Icons.call_outlined,
                        label: 'Call Parent',
                        color: Color(AppColors.secondary),
                        onTap: () => _callParent(context),
                      ),
                      _buildActionButton(
                        icon: Icons.note_outlined,
                        label: 'Log Note',
                        color: Color(AppColors.info),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Color(AppColors.primary),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(AppColors.primary),
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Attendance'),
                      Tab(text: 'Grades'),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      children: [
                        _buildDetailsTab(),
                        _buildAttendanceTab(),
                        _buildGradesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information
          _buildSectionTitle('Personal Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Date of Birth', _formatDate(student['dateOfBirth'])),
          _buildInfoRow('Gender', (student['gender']?.toString() ?? 'N/A').capitalize()),
          _buildInfoRow('Blood Group', student['bloodGroup'] ?? 'N/A'),
          _buildInfoRow('Admission No', student['admissionNumber'] ?? 'N/A'),
          _buildInfoRow('Admission Date', _formatDate(student['admissionDate'])),
          _buildInfoRow('Address', student['address'] ?? 'N/A'),
          
          const SizedBox(height: 24),
          
          // Parent/Guardian Contact
          _buildSectionTitle('Parent/Guardian Contact'),
          const SizedBox(height: 12),
          _buildContactRow(
            'Name',
            student['emergencyContact']?['fatherName'] ?? 'N/A',
            hasActions: true,
          ),
          _buildInfoRow('Email', student['parentId']?['email'] ?? 'N/A'),
          _buildInfoRow('Phone', student['emergencyContact']?['phone'] ?? 'N/A'),
          
          const SizedBox(height: 24),
          
          // Emergency Contact
          _buildSectionTitle('Emergency Contact'),
          const SizedBox(height: 12),
          _buildContactRow(
            'Name',
            '${student['emergencyContact']?['motherName'] ?? 'N/A'} (${(student['emergencyContact']?['relation']?.toString() ?? 'N/A').capitalize()})',
            hasActions: false,
          ),
          _buildInfoRow('Phone', student['emergencyContact']?['phone'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Attendance records will be displayed here',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.grade,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Grade records will be displayed here',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value, {required bool hasActions}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (hasActions) ...[
            const SizedBox(width: 8),
            Icon(Icons.message_outlined, size: 18, color: Color(AppColors.primary)),
            const SizedBox(width: 8),
            Icon(Icons.call_outlined, size: 18, color: Color(AppColors.secondary)),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'S';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      DateTime dateTime = date is String ? DateTime.parse(date) : date;
      return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  void _callParent(BuildContext context) {
    final phone = student['emergencyContact']?['phone'];
    if (phone != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling $phone...'),
          backgroundColor: Color(AppColors.success),
        ),
      );
    }
  }
}
