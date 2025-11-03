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
  String _filterStatus = 'all'; // all, assigned, unassigned

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

        if (_filterStatus == 'all') return matchesSearch;

        final assignments = _getTeacherAssignments(teacher['_id']);
        final hasAssignments = assignments['classes'].isNotEmpty ||
            assignments['subjects'].isNotEmpty;

        if (_filterStatus == 'assigned') {
          return matchesSearch && hasAssignments;
        } else {
          return matchesSearch && !hasAssignments;
        }
      }).toList();
    });
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
      appBar: AppBar(
        title: const Text('Teacher Assignments'),
        backgroundColor: const Color(0xFFBA78FC),
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
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search and Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or email...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Filter: '),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('All Teachers'),
                            selected: _filterStatus == 'all',
                            onSelected: (selected) {
                              setState(() => _filterStatus = 'all');
                              _filterTeachers();
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Assigned'),
                            selected: _filterStatus == 'assigned',
                            selectedColor: Colors.green[200],
                            onSelected: (selected) {
                              setState(() => _filterStatus = 'assigned');
                              _filterTeachers();
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Unassigned'),
                            selected: _filterStatus == 'unassigned',
                            selectedColor: Colors.orange[200],
                            onSelected: (selected) {
                              setState(() => _filterStatus = 'unassigned');
                              _filterTeachers();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Teachers List
                Expanded(
                  child: _filteredTeachers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off,
                                  size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No teachers found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
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

  Widget _buildTeacherCard(
      Map<String, dynamic> teacher, Map<String, dynamic> assignments) {
    final classCount = assignments['classes'].length;
    final subjectCount = assignments['subjects'].length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFBA78FC),
              child: Text(
                teacher['profile']?['name']?.substring(0, 1).toUpperCase() ??
                    'T',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teacher['email'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusChip(
                        Icons.class_,
                        '$classCount Class${classCount != 1 ? 'es' : ''}',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        Icons.book,
                        '$subjectCount Subject${subjectCount != 1 ? 's' : ''}',
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Edit Button
            IconButton(
              onPressed: () => _showAssignmentDialog(teacher),
              icon: const Icon(Icons.edit),
              color: const Color(0xFFBA78FC),
              tooltip: 'Edit Assignments',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
