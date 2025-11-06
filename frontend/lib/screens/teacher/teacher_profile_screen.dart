import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';
import 'teacher_edit_profile_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final ApiService _apiService = getIt<ApiService>();
  
  Map<String, dynamic>? _teacherData;
  List<Map<String, dynamic>> _assignedClasses = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
    setState(() => _isLoading = true);
    try {
      // Get current user profile
      final userResponse = await _apiService.get('/auth/me');
      final userData = userResponse.data['data']['user'];
      
      // Get teacher assignments (classes and subjects)
      final assignmentsResponse = await _apiService.get('/teacher/assignments');
      final assignmentsData = assignmentsResponse.data['data'];
      
      setState(() {
        _teacherData = userData;
        _assignedClasses = List<Map<String, dynamic>>.from(
          assignmentsData['classes'] ?? []
        );
        _subjects = List<Map<String, dynamic>>.from(
          assignmentsData['subjects'] ?? []
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _teacherData == null ? null : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherEditProfileScreen(
                    teacherData: _teacherData!,
                  ),
                ),
              );
              
              // Reload profile if changes were saved
              if (result == true) {
                _loadTeacherProfile();
              }
            },
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFFBA78FC),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFE5B87E),
                          child: _teacherData?['profile']?['avatar'] != null
                              ? ClipOval(
                                  child: Image.network(
                                    _teacherData!['profile']['avatar'],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          _teacherData?['profile']?['name'] ?? 'Teacher',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Designation
                        Text(
                          _getDesignation(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Contact Information
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildContactItem(
                          Icons.email_outlined,
                          'Email',
                          _teacherData?['email'] ?? 'N/A',
                          const Color(0xFFBA78FC),
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          Icons.phone_outlined,
                          'Phone Number',
                          _teacherData?['profile']?['phone'] ?? 'N/A',
                          const Color(0xFFBA78FC),
                        ),
                        const SizedBox(height: 16),
                        _buildContactItem(
                          Icons.badge_outlined,
                          'Staff ID',
                          _teacherData?['employeeId'] ?? 'N/A',
                          const Color(0xFFBA78FC),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Academic Assignments
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Academic Assignments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Assigned Classes
                        _buildAssignmentSection(
                          Icons.school_outlined,
                          'Assigned Classes',
                          _assignedClasses.isNotEmpty
                              ? _assignedClasses
                                  .map((c) => c['name'] ?? '')
                                  .join(', ')
                              : 'No classes assigned',
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Subjects
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBA78FC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.menu_book_outlined,
                                color: Color(0xFFBA78FC),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Subjects',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _subjects.isEmpty
                                      ? const Text(
                                          'No subjects assigned',
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _subjects.map((subject) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFBA78FC)
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                subject['name'] ?? '',
                                                style: const TextStyle(
                                                  color: Color(0xFFBA78FC),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  String _getDesignation() {
    if (_subjects.isEmpty) return 'Teacher';
    
    if (_subjects.length == 1) {
      return '${_subjects[0]['name']} Teacher';
    }
    
    // Get primary subject (first one)
    return 'Senior ${_subjects[0]['name']} Teacher';
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentSection(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFBA78FC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFBA78FC),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
