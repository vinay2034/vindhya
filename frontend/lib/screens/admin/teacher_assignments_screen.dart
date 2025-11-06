import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';
import 'teacher_registration_screen.dart';

class TeacherAssignmentsScreen extends StatefulWidget {
  const TeacherAssignmentsScreen({Key? key}) : super(key: key);

  @override
  State<TeacherAssignmentsScreen> createState() =>
      _TeacherAssignmentsScreenState();
}

class _TeacherAssignmentsScreenState extends State<TeacherAssignmentsScreen> {
  final ApiService _apiService = getIt<ApiService>();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _teachers = [];
  List<dynamic> _filteredTeachers = [];
  List<dynamic> _classes = [];
  List<dynamic> _subjects = [];
  List<dynamic> _timetable = [];

  bool _isLoading = true;
  String _selectedDepartment = 'All'; // All, Science Dept., Arts Dept., Available

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterTeachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.get('/admin/users', queryParameters: {'role': 'teacher'}),
        _apiService.get('/admin/classes'),
        _apiService.get('/admin/subjects'),
        _apiService.get('/admin/timetable'),
      ]);

      setState(() {
        _teachers = results[0].data['data']['users'] ?? [];
        _classes = results[1].data['data']['classes'] ?? [];
        _subjects = results[2].data['data']['subjects'] ?? [];
        _timetable = results[3].data['data']['timetable'] ?? [];
        _filteredTeachers = _teachers;
      });
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterTeachers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTeachers = _teachers.where((teacher) {
        final name = teacher['profile']?['name']?.toLowerCase() ?? '';
        final email = teacher['email']?.toLowerCase() ?? '';
        final matchesSearch = name.contains(query) || email.contains(query);

        if (!matchesSearch) return false;

        // Department filter
        if (_selectedDepartment == 'All') return true;

        final assignments = _getTeacherAssignments(teacher['_id']);
        final hasAssignments = assignments['classes'].isNotEmpty ||
            assignments['subjects'].isNotEmpty;

        if (_selectedDepartment == 'Available') {
          return !hasAssignments || _getWorkloadPercentage(assignments) < 50;
        }

        // Get teacher's department from subjects
        final teacherDept = _getTeacherDepartment(assignments['subjects']);
        return teacherDept == _selectedDepartment;
      }).toList();
    });
  }

  String _getTeacherDepartment(List subjects) {
    if (subjects.isEmpty) return 'None';
    
    for (var subject in subjects) {
      final subjectName = subject['subjectName']?.toLowerCase() ?? '';
      if (subjectName.contains('science') ||
          subjectName.contains('physics') ||
          subjectName.contains('chemistry') ||
          subjectName.contains('biology') ||
          subjectName.contains('math')) {
        return 'Science Dept.';
      } else if (subjectName.contains('english') ||
          subjectName.contains('history') ||
          subjectName.contains('geography') ||
          subjectName.contains('art') ||
          subjectName.contains('music')) {
        return 'Arts Dept.';
      }
    }
    return 'Other';
  }

  int _getWorkloadPercentage(Map<String, dynamic> assignments) {
    // Calculate workload based on classes and subjects
    final classCount = assignments['classes'].length;
    final subjectCount = assignments['subjects'].length;
    
    // Each class as class teacher = 30%, each subject = 20%
    // Max realistic: 2 classes (60%) + 2 subjects (40%) = 100%
    final classLoad = classCount * 30;
    final subjectLoad = subjectCount * 20;
    final totalLoad = classLoad + subjectLoad;
    
    return totalLoad > 100 ? 100 : totalLoad;
  }

  Color _getWorkloadColor(int percentage) {
    if (percentage >= 80) return Colors.red;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return const Color(0xFFBA78FC);
    return Colors.green;
  }

  Map<String, dynamic> _getTeacherAssignments(String teacherId) {
    final assignedClasses = _classes
        .where((cls) => cls['classTeacher']?['_id'] == teacherId)
        .toList();

    final assignedSubjects = _timetable
        .where((entry) => entry['teacherId']?['_id'] == teacherId)
        .map((entry) => entry['subjectId'])
        .toSet()
        .toList();

    return {
      'classes': assignedClasses,
      'subjects': assignedSubjects,
    };
  }

  void _showAssignmentDialog(Map<String, dynamic> teacher) {
    final teacherId = teacher['_id'];
    final assignments = _getTeacherAssignments(teacherId);

    List<String> selectedClassIds = assignments['classes']
        .map<String>((cls) => cls['_id'].toString())
        .toList();

    List<String> selectedSubjectIds = assignments['subjects']
        .map<String>((sub) => sub['_id'].toString())
        .toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Assign Classes & Subjects\n${teacher['profile']?['name'] ?? teacher['email']}',
            style: const TextStyle(fontSize: 18),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Class Teacher',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._classes.map((cls) {
                    final classId = cls['_id'];
                    final isSelected = selectedClassIds.contains(classId);
                    return CheckboxListTile(
                      title: Text('${cls['className']} ${cls['section']}'),
                      subtitle: Text('Room: ${cls['room'] ?? 'Not assigned'}'),
                      value: isSelected,
                      activeColor: const Color(0xFFBA78FC),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (!selectedClassIds.contains(classId)) {
                              selectedClassIds.add(classId);
                            }
                          } else {
                            selectedClassIds.remove(classId);
                          }
                        });
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Teaching Subjects',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._subjects.map((subject) {
                    final subjectId = subject['_id'];
                    final isSelected = selectedSubjectIds.contains(subjectId);
                    return CheckboxListTile(
                      title: Text(subject['name']),
                      subtitle: Text('Code: ${subject['code'] ?? 'N/A'}'),
                      value: isSelected,
                      activeColor: const Color(0xFFBA78FC),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (!selectedSubjectIds.contains(subjectId)) {
                              selectedSubjectIds.add(subjectId);
                            }
                          } else {
                            selectedSubjectIds.remove(subjectId);
                          }
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _saveAssignments(
                  teacherId,
                  selectedClassIds,
                  selectedSubjectIds,
                );
                Navigator.pop(context);
              },
              child: const Text('Save Assignments'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAssignments(
    String teacherId,
    List<String> classIds,
    List<String> subjectIds,
  ) async {
    try {
      // Update class teacher assignments
      for (final cls in _classes) {
        final classId = cls['_id'];
        final shouldBeAssigned = classIds.contains(classId);
        final isCurrentlyAssigned = cls['classTeacher']?['_id'] == teacherId;

        if (shouldBeAssigned && !isCurrentlyAssigned) {
          await _apiService.put(
            '/admin/classes/$classId',
            data: {'classTeacher': teacherId},
          );
        } else if (!shouldBeAssigned && isCurrentlyAssigned) {
          await _apiService.put(
            '/admin/classes/$classId',
            data: {'classTeacher': null},
          );
        }
      }

      _showSuccess('Assignments updated successfully');
      await _loadData();
    } catch (e) {
      _showError('Failed to update assignments: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Teacher Assignments'),
        backgroundColor: const Color(0xFFBA78FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Menu options
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TeacherRegistrationScreen(),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: const Color(0xFFBA78FC),
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 6,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBA78FC)),
            ))
          : Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a teacher',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFBA78FC),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                // Department Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Science Dept.'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Arts Dept.'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Available'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Teachers List
                Expanded(
                  child: _filteredTeachers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off,
                                  size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No teachers found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = _filteredTeachers[index];
                            final assignments =
                                _getTeacherAssignments(teacher['_id']);
                            return _buildTeacherCard(teacher, assignments);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedDepartment == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDepartment = label;
          _filterTeachers();
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFBA78FC).withOpacity(0.2),
      checkmarkColor: const Color(0xFFBA78FC),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFBA78FC) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFFBA78FC) : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildTeacherCard(
      Map<String, dynamic> teacher, Map<String, dynamic> assignments) {
    final classCount = assignments['classes'].length;
    final subjectCount = assignments['subjects'].length;
    final workloadPercent = _getWorkloadPercentage(assignments);
    final workloadColor = _getWorkloadColor(workloadPercent);

    return GestureDetector(
      onTap: () => _showAssignmentDialog(teacher),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFBA78FC),
                          const Color(0xFFBA78FC).withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        teacher['profile']?['name']
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'T',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Teacher Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher['profile']?['name'] ?? teacher['email'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$classCount Class${classCount != 1 ? 'es' : ''}, $subjectCount Club${subjectCount != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit Icon
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      color: Colors.grey[700],
                      onPressed: () => _showAssignmentDialog(teacher),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Workload Section
              Row(
                children: [
                  Text(
                    'Workload: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$workloadPercent%',
                    style: TextStyle(
                      fontSize: 14,
                      color: workloadColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: workloadPercent / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(workloadColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
