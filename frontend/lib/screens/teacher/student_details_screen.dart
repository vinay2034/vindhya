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
    _tabController = TabController(length: 3, vsync: this);
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
      child: Row(
        children: [
          // Left side - Profile Picture
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
          const SizedBox(width: 16),
          
          // Right side - Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  student['name'] ?? 'Student Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Student ID
                Text(
                  'Student ID: ${student['admissionNumber'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),

                // Grade
                Text(
                  'Grade ${student['classId']?['grade'] ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
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
          _buildInfoRow('Gender', _capitalizeFirst(student['gender'] ?? 'N/A')),
          _buildInfoRow('Address', student['address'] ?? 'N/A'),
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
    // Generate last 7 days
    final List<Map<String, dynamic>> last7Days = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Sample data - in real app, fetch from backend
      final status = i % 3 == 0 ? 'Present' : (i % 5 == 0 ? 'Absent' : 'Present');
      last7Days.add({
        'date': date,
        'status': status,
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 7 Days Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Last 7 days attendance list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: last7Days.length,
            itemBuilder: (context, index) {
              final record = last7Days[index];
              final date = record['date'] as DateTime;
              final status = record['status'] as String;
              final isPresent = status == 'Present';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPresent ? Colors.green.shade200 : Colors.red.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Date
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE').format(date),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            DateFormat('MMM dd, yyyy').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isPresent ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPresent ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: TextStyle(
                              color: isPresent ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
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

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
