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
  String? _selectedSubjectId;
  
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _students = [];
  Map<String, String> _attendanceStatus = {}; // studentId: status
  
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
      final classesResponse = await _apiService.get('/admin/classes');
      final subjectsResponse = await _apiService.get('/admin/subjects');
      
      setState(() {
        _classes = List<Map<String, dynamic>>.from(classesResponse.data['classes'] ?? []);
        _subjects = List<Map<String, dynamic>>.from(subjectsResponse.data['subjects'] ?? []);
        
        // Select first class and subject by default
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes[0]['_id'];
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
      final response = await _apiService.get('/admin/students?classId=$_selectedClassId');
      final students = List<Map<String, dynamic>>.from(response.data['students'] ?? []);
      
      // Try to load existing attendance for this date
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      try {
        final attendanceResponse = await _apiService.get(
          '/teacher/attendance?date=$dateStr&classId=$_selectedClassId&subjectId=$_selectedSubjectId'
        );
        
        final existingAttendance = attendanceResponse.data['attendance'];
        if (existingAttendance != null) {
          _attendanceStatus.clear();
          for (var record in existingAttendance['records'] ?? []) {
            _attendanceStatus[record['studentId']] = record['status'];
          }
        }
      } catch (e) {
        // No existing attendance, start fresh
        _attendanceStatus.clear();
      }
      
      setState(() {
        _students = students;
        _isLoading = false;
        _calculateStats();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  void _calculateStats() {
    _presentCount = 0;
    _absentCount = 0;
    _lateCount = 0;
    
    for (var status in _attendanceStatus.values) {
      if (status == 'present') _presentCount++;
      else if (status == 'absent') _absentCount++;
      else if (status == 'late') _lateCount++;
    }
  }

  void _setAttendance(String studentId, String status) {
    setState(() {
      if (_attendanceStatus[studentId] == status) {
        // Toggle off if clicking same status
        _attendanceStatus.remove(studentId);
      } else {
        _attendanceStatus[studentId] = status;
      }
      _calculateStats();
    });
  }

  Future<void> _saveAttendance() async {
    if (_selectedClassId == null || _selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select class and subject')),
      );
      return;
    }
    
    if (_attendanceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark attendance for at least one student')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final records = _attendanceStatus.entries.map((entry) => {
        'studentId': entry.key,
        'status': entry.value,
      }).toList();
      
      await _apiService.post(
        '/teacher/attendance',
        data: {
          'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
          'classId': _selectedClassId,
          'subjectId': _selectedSubjectId,
          'records': records,
        },
      );
      
      setState(() => _isSaving = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving attendance: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBA78FC),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Student Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
                // Calendar Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month - 1,
                                );
                              });
                              _loadStudents();
                            },
                          ),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Text(
                              DateFormat('MMMM yyyy').format(_selectedDate),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month + 1,
                                );
                              });
                              _loadStudents();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCalendar(),
                    ],
                  ),
                ),
                
                // Class/Subject Tabs
                if (_classes.isNotEmpty && _subjects.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ..._classes.take(2).map((classItem) {
                            final className = classItem['name'] ?? 'Class';
                            final subject = _subjects.isNotEmpty 
                                ? _subjects[_classes.indexOf(classItem) % _subjects.length]
                                : null;
                            final subjectName = subject?['name'] ?? 'Subject';
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ChoiceChip(
                                label: Text('$className - $subjectName'),
                                selected: _selectedClassId == classItem['_id'],
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedClassId = classItem['_id'];
                                      _selectedSubjectId = subject?['_id'];
                                    });
                                    _loadStudents();
                                  }
                                },
                                selectedColor: const Color(0xFFBA78FC),
                                labelStyle: TextStyle(
                                  color: _selectedClassId == classItem['_id']
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                
                // Attendance Summary
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attendance Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Present: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$_presentCount/${_students.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Absent: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$_absentCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Late: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$_lateCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Student List
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Student List (${_students.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              height: 36,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search student...',
                                  prefixIcon: const Icon(Icons.search, size: 20),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _students.isEmpty
                              ? const Center(
                                  child: Text('No students found'),
                                )
                              : ListView.builder(
                                  itemCount: _students.length,
                                  itemBuilder: (context, index) {
                                    final student = _students[index];
                                    final studentId = student['_id'];
                                    final status = _attendanceStatus[studentId];
                                    
                                    return _buildStudentItem(
                                      student['name'] ?? 'Student',
                                      student['rollNumber'] ?? index + 1,
                                      student['avatar'],
                                      studentId,
                                      status,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Save Button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveAttendance,
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
                              'Save Attendance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;
    
    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => SizedBox(
                    width: 40,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar grid
        Wrap(
          children: List.generate(42, (index) {
            final dayNumber = index - firstWeekday + 2;
            
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox(
                width: 40,
                height: 40,
              );
            }
            
            final date = DateTime(_selectedDate.year, _selectedDate.month, dayNumber);
            final isSelected = date.year == _selectedDate.year &&
                date.month == _selectedDate.month &&
                date.day == _selectedDate.day;
            final isToday = date.year == now.year &&
                date.month == now.month &&
                date.day == now.day;
            
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
                _loadStudents();
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFBA78FC)
                      : isToday
                          ? const Color(0xFFBA78FC).withOpacity(0.2)
                          : null,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$dayNumber',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? const Color(0xFFBA78FC)
                            : Colors.black87,
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStudentItem(
    String name,
    dynamic rollNo,
    String? avatar,
    String studentId,
    String? status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Student Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFBA78FC).withOpacity(0.2),
            backgroundImage: avatar != null && avatar.isNotEmpty
                ? NetworkImage('${ApiConfig.baseUrl.replaceAll('/api', '')}$avatar')
                : null,
            child: avatar == null || avatar.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      color: Color(0xFFBA78FC),
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Roll No: ${rollNo.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Attendance Buttons
          Row(
            children: [
              _buildAttendanceButton(
                Icons.check,
                status == 'present',
                Colors.green,
                () => _setAttendance(studentId, 'present'),
              ),
              const SizedBox(width: 8),
              _buildAttendanceButton(
                Icons.close,
                status == 'absent',
                Colors.red,
                () => _setAttendance(studentId, 'absent'),
              ),
              const SizedBox(width: 8),
              _buildAttendanceButton(
                Icons.schedule,
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

  Widget _buildAttendanceButton(
    IconData icon,
    bool isSelected,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }
}
