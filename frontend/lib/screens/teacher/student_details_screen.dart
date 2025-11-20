import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';
import '../../utils/constants.dart';

class StudentDetailsScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = getIt<ApiService>();

  Map<String, dynamic>? _studentData;
  Map<String, dynamic>? _attendanceData;
  bool _isLoading = true;
  String _selectedYear = '2023-2024';
  late TabController _tabController;

  final List<String> _academicYears = ['2022-2023', '2023-2024', '2024-2025'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStudentDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentDetails() async {
    setState(() => _isLoading = true);
    try {
      // Get student details
      final studentResponse = await _apiService.get('/teacher/student/${widget.studentId}');
      
      // Get attendance data
      final attendanceResponse = await _apiService.get('/teacher/attendance?studentId=${widget.studentId}');
      
      setState(() {
        _studentData = studentResponse.data['data'];
        _attendanceData = attendanceResponse.data['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading student details: $e')),
        );
      }
    }
  }

  void _launchPhone(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Call: $phone')),
    );
  }

  void _launchEmail(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email: $email')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Student Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show options menu
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(),

                  // Tabs
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFFBA78FC),
                      unselectedLabelColor: Colors.grey[600],
                      indicatorColor: const Color(0xFFBA78FC),
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: 'Details'),
                        Tab(text: 'Attendance'),
                        Tab(text: 'Grades'),
                        Tab(text: 'Communication'),
                      ],
                    ),
                  ),

                  // Tab Content
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDetailsTab(),
                        _buildAttendanceTab(),
                        _buildGradesTab(),
                        _buildCommunicationTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    final student = _studentData ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 40,
            backgroundImage: student['avatar'] != null
                ? NetworkImage('${ApiConfig.baseUrl.replaceAll('/api', '')}${student['avatar']}')
                : null,
            backgroundColor: const Color(0xFFE5B87E),
            child: student['avatar'] == null
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            student['name'] ?? 'Student Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Student ID and Grade
          Text(
            'Student ID: ${student['admissionNumber'] ?? 'N/A'} | Grade ${student['classId']?['grade'] ?? ''}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Contact Parent Button
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                _showContactParentDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA78FC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Contact Parent',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Academic Year Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _academicYears.map((year) {
              final isSelected = year == _selectedYear;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(year),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedYear = year);
                    }
                  },
                  selectedColor: const Color(0xFFBA78FC),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    final student = _studentData ?? {};
    final emergencyContact = student['emergencyContact'] ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personal Information
          _buildSectionTitle('Personal Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Date of Birth', _formatDate(student['dateOfBirth'])),
          _buildInfoRow('Gender', _capitalizeFirst(student['gender'] ?? 'N/A')),
          _buildInfoRow('Address', student['address'] ?? 'N/A'),
          const SizedBox(height: 24),

          // Guardian Information
          _buildSectionTitle('Guardian Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Guardian', emergencyContact['fatherName'] ?? 'N/A'),
          _buildInfoRow(
            'Contact',
            emergencyContact['phone'] ?? 'N/A',
            isLink: true,
            onTap: () => _launchPhone(emergencyContact['phone'] ?? ''),
          ),
          _buildInfoRow(
            'Email',
            student['parentId']?['email'] ?? 'N/A',
            isLink: true,
            onTap: () => _launchEmail(student['parentId']?['email'] ?? ''),
          ),
          const SizedBox(height: 24),

          // Emergency Contact
          _buildSectionTitle('Emergency Contact'),
          const SizedBox(height: 12),
          _buildInfoRow('Name', emergencyContact['fatherName'] ?? 'N/A'),
          _buildInfoRow('Relationship', 'Father'),
          _buildInfoRow(
            'Contact',
            emergencyContact['phone'] ?? 'N/A',
            isLink: true,
            onTap: () => _launchPhone(emergencyContact['phone'] ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    final attendance = _attendanceData ?? {};
    final present = attendance['present'] ?? 0;
    final absent = attendance['absent'] ?? 0;
    final late = attendance['late'] ?? 0;
    final total = present + absent + late;
    final percentage = total > 0 ? ((present / total) * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Expandable Attendance Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ExpansionTile(
              title: const Row(
                children: [
                  Icon(Icons.bar_chart, color: Color(0xFFBA78FC)),
                  SizedBox(width: 12),
                  Text(
                    'Attendance',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Circular Progress
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFBA78FC),
                                ),
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBA78FC),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Attendance Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildAttendanceStat('Present', present, Colors.green),
                          _buildAttendanceStat('Absent', absent, Colors.red),
                          _buildAttendanceStat('Late', late, Colors.orange),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grade_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No grades available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No communication history',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
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

  Widget _buildInfoRow(String label, String value, {bool isLink = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: isLink ? onTap : null,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isLink ? const Color(0xFFBA78FC) : Colors.black87,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, int count, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count $label',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(date.toString());
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showContactParentDialog() {
    final student = _studentData ?? {};
    final emergencyContact = student['emergencyContact'] ?? {};
    final phone = emergencyContact['phone'] ?? '';
    final email = student['parentId']?['email'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Parent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFFBA78FC)),
              title: Text(phone.isNotEmpty ? phone : 'No phone number'),
              onTap: phone.isNotEmpty
                  ? () {
                      Navigator.pop(context);
                      _launchPhone(phone);
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFFBA78FC)),
              title: Text(email.isNotEmpty ? email : 'No email'),
              onTap: email.isNotEmpty
                  ? () {
                      Navigator.pop(context);
                      _launchEmail(email);
                    }
                  : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
