import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';
import '../../utils/constants.dart';

class StudentAttendanceScreen extends StatefulWidget {
  const StudentAttendanceScreen({super.key});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final ApiService _apiService = getIt<ApiService>();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedClassId;
  String? _selectedClassName;
  String? _selectedSubjectId;
  
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _students = [];
  final Map<String, String> _attendanceStatus = {}; // studentId: status
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  int _presentCount = 0;
  int _absentCount = 0;
  int _lateCount = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Load classes and subjects
      final classesResponse = await _apiService.get('/teacher/classes');
      final subjectsResponse = await _apiService.get('/teacher/subjects');
      
      // The backend returns data directly in the 'data' field (not nested)
      final classesData = classesResponse.data['data'];
      final subjectsData = subjectsResponse.data['data'];
      
      final classes = List<Map<String, dynamic>>.from(
        classesData is List ? classesData : []
      );
      final subjects = List<Map<String, dynamic>>.from(
        subjectsData is List ? subjectsData : []
      );
      
      setState(() {
        _classes = classes;
        _subjects = subjects;
        
        // Select first class and subject by default
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes[0]['_id'];
          _selectedClassName = '${_classes[0]['className']} - Section ${_classes[0]['section'] ?? 'A'}';
        }
        if (_subjects.isNotEmpty) {
          _selectedSubjectId = _subjects[0]['_id'];
        }
        
        _isLoading = false;
      });
      
      if (_selectedClassId != null) {
        await _loadStudents();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedClassId == null) return;
    
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/teacher/students/$_selectedClassId');
      final students = List<Map<String, dynamic>>.from(response.data['data']['students'] ?? []);
      
      setState(() {
        _students = students;
        _isLoading = false;
      });
      
      _calculateSummary();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  void _calculateSummary() {
    int present = 0;
    int absent = 0;
    int late = 0;
    
    _attendanceStatus.forEach((key, value) {
      if (value == 'present') {
        present++;
      } else if (value == 'absent') absent++;
      else if (value == 'late') late++;
    });
    
    setState(() {
      _presentCount = present;
      _absentCount = absent;
      _lateCount = late;
    });
  }

  void _setAttendance(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
    _calculateSummary();
  }

  Future<void> _markAllPresent() async {
    setState(() {
      for (var student in _students) {
        _attendanceStatus[student['_id']] = 'present';
      }
    });
    _calculateSummary();
  }

  Future<void> _submitAttendance() async {
    if (_selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No subjects assigned. Please contact admin to assign subjects.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subject'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_attendanceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark attendance for at least one student'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final records = _attendanceStatus.entries.map((entry) => {
        'studentId': entry.key,
        'status': entry.value,
      }).toList();

      await _apiService.post('/teacher/attendance/bulk', data: {
        'classId': _selectedClassId,
        'subjectId': _selectedSubjectId,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'records': records,
      });

      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting attendance: $e')),
        );
      }
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Student Attendance',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Class/Subject Tabs
                if (_classes.isNotEmpty) _buildClassTabs(),
                
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Date Selector
                      _buildDateSelector(),
                      const SizedBox(height: 20),

                      // Today's Summary
                      const Text(
                        "Today's Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCards(),
                      const SizedBox(height: 24),

                      // Student Roster Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Student Roster',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: _markAllPresent,
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFBA78FC).withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Mark All Present',
                              style: TextStyle(
                                color: Color(0xFFBA78FC),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Student List
                      _buildStudentList(),
                    ],
                  ),
                ),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
    );
  }

  Widget _buildClassTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Label
          const Text(
            'Select Class',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // Class Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _classes.asMap().entries.map((entry) {
                final index = entry.key;
                final classData = entry.value;
                final isSelected = _selectedClassId == classData['_id'];
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Grade ${classData['grade']} - ${classData['className'] ?? 'Class'}'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedClassId = classData['_id'];
                          _tabController.animateTo(index);
                        });
                        _loadStudents();
                      }
                    },
                    selectedColor: const Color(0xFFBA78FC),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subject Label
          const Text(
            'Select Subject',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          // Subject Chips
          if (_subjects.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _subjects.map((subject) {
                  final isSelected = _selectedSubjectId == subject['_id'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(subject['name'] ?? 'Subject'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedSubjectId = subject['_id'];
                          });
                        }
                      },
                      selectedColor: const Color(0xFFBA78FC),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey[200],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No subjects assigned. Please contact admin to assign subjects before marking attendance.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                DateFormat('EEEE, MMM d').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard('Present', _presentCount, Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard('Absent', _absentCount, Colors.red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard('Late', _lateCount, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (_students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'No students found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _students.map((student) {
        return _buildStudentCard(student);
      }).toList(),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final studentId = student['_id'];
    final name = student['name'] ?? 'Student';
    final avatar = student['avatar'];
    final status = _attendanceStatus[studentId];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE5B87E),
            backgroundImage: avatar != null && avatar.isNotEmpty
                ? NetworkImage('${ApiConfig.baseUrl.replaceAll('/api', '')}$avatar')
                : null,
            child: avatar == null || avatar.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Attendance Buttons
          Row(
            children: [
              _buildAttendanceChip(
                'Present',
                status == 'present',
                Colors.green,
                () => _setAttendance(studentId, 'present'),
              ),
              const SizedBox(width: 8),
              _buildAttendanceChip(
                'Absent',
                status == 'absent',
                Colors.red,
                () => _setAttendance(studentId, 'absent'),
              ),
              const SizedBox(width: 8),
              _buildAttendanceChip(
                'Late',
                status == 'late',
                Colors.orange,
                () => _setAttendance(studentId, 'late'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChip(String label, bool isSelected, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _submitAttendance,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBA78FC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Submit Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
