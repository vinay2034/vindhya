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
      final classesResponse = await _apiService.get('/teacher/classes');
      final subjectsResponse = await _apiService.get('/teacher/subjects');
      
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
        
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes[0]['_id'];
          _selectedClassName = 'Grade ${_classes[0]['grade']} - Section ${_classes[0]['section'] ?? 'A'}';
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
        _attendanceStatus.clear();
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

  void _showClassPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Class',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._classes.map((classData) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA78FC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.class_outlined,
                      color: Color(0xFFBA78FC),
                    ),
                  ),
                  title: Text('Grade ${classData['grade']} - Section ${classData['section'] ?? 'A'}'),
                  onTap: () {
                    setState(() {
                      _selectedClassId = classData['_id'];
                      _selectedClassName = 'Grade ${classData['grade']} - Section ${classData['section'] ?? 'A'}';
                    });
                    Navigator.pop(context);
                    _loadStudents();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBA78FC),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedDate = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Class and Date Header
                _buildClassDateHeader(),
                
                // Summary Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSummaryCards(),
                ),
                
                // Student List Header
                _buildStudentListHeader(),
                
                const Divider(height: 1),
                
                // Student List
                Expanded(
                  child: _buildStudentList(),
                ),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
    );
  }

  Widget _buildClassDateHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Class Selector
          Expanded(
            child: InkWell(
              onTap: _showClassPicker,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA78FC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.class_outlined,
                      color: Color(0xFFBA78FC),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedClassName ?? 'Select Class',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFBA78FC),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFBA78FC),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Date Selector
          InkWell(
            onTap: _showDatePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.black54,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d,\nyyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black54,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            count: _presentCount,
            label: 'Present',
            color: const Color(0xFF4CAF50),
            backgroundColor: const Color(0xFFE8F5E9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            count: _absentCount,
            label: 'Absent',
            color: const Color(0xFFE57373),
            backgroundColor: const Color(0xFFFFEBEE),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            count: _lateCount,
            label: 'Late',
            color: const Color(0xFFFFA726),
            backgroundColor: const Color(0xFFFFF3E0),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required int count,
    required String label,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Student List (${_students.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: _markAllPresent,
            child: const Text(
              'Mark All Present',
              style: TextStyle(
                color: Color(0xFFBA78FC),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    if (_students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final student = _students[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final name = student['name'] ?? 'Student';
    final rollNumber = student['rollNumber'] ?? 'N/A';
    final avatar = student['avatar'];
    final studentId = student['_id'];
    final status = _attendanceStatus[studentId];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFBA78FC).withOpacity(0.1),
            backgroundImage: avatar != null && avatar.isNotEmpty
                ? NetworkImage('${ApiConfig.baseUrl.replaceAll('/api', '')}$avatar')
                : null,
            child: avatar == null || avatar.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: Color(0xFFBA78FC),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // Name and Roll Number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Roll No: $rollNumber',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Attendance Buttons
          Row(
            children: [
              _buildAttendanceButton(
                icon: Icons.check,
                color: const Color(0xFF4CAF50),
                isSelected: status == 'present',
                onTap: () => _setAttendance(studentId, 'present'),
              ),
              const SizedBox(width: 8),
              _buildAttendanceButton(
                icon: Icons.close,
                color: const Color(0xFFE57373),
                isSelected: status == 'absent',
                onTap: () => _setAttendance(studentId, 'absent'),
              ),
              const SizedBox(width: 8),
              _buildAttendanceButton(
                icon: Icons.schedule,
                color: const Color(0xFFFFA726),
                isSelected: status == 'late',
                onTap: () => _setAttendance(studentId, 'late'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceButton({
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey[600],
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
            foregroundColor: Colors.white,
            elevation: 0,
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
                  'Save Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
