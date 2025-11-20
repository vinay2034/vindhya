import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final ApiService _apiService = getIt<ApiService>();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedClassId;
  String? _selectedClassName;
  
  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];
  Map<String, String> _attendanceStatus = {}; // studentId: status
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  int get _presentCount => _attendanceStatus.values.where((s) => s == 'present').length;
  int get _absentCount => _attendanceStatus.values.where((s) => s == 'absent').length;
  int get _lateCount => _attendanceStatus.values.where((s) => s == 'late').length;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/teacher/classes');
      final classes = List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      
      setState(() {
        _classes = classes;
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes[0]['_id'];
          _selectedClassName = '${_classes[0]['className']} - Section ${_classes[0]['section']}';
          _loadStudents();
        } else {
          _isLoading = false;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading classes: $e')),
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
        
        // Initialize attendance status for all students as present
        _attendanceStatus.clear();
        for (var student in students) {
          _attendanceStatus[student['_id']] = 'present';
        }
        
        _isLoading = false;
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

  void _setAttendanceStatus(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  void _markAllPresent() {
    setState(() {
      for (var student in _students) {
        _attendanceStatus[student['_id']] = 'present';
      }
    });
  }

  Future<void> _submitAttendance() async {
    if (_selectedClassId == null) return;
    
    setState(() => _isSaving = true);
    try {
      final attendanceData = _students.map((student) {
        final studentId = student['_id'];
        return {
          'studentId': studentId,
          'status': _attendanceStatus[studentId] ?? 'present',
        };
      }).toList();

      final requestData = {
        'classId': _selectedClassId,
        'date': _selectedDate.toIso8601String(),
        'attendance': attendanceData,
      };

      await _apiService.post('/teacher/attendance/bulk', data: requestData);
      
      setState(() => _isSaving = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF9C27B0),
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
    }
  }

  Future<void> _selectClass() async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Class'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _classes.length,
            itemBuilder: (context, index) {
              final classData = _classes[index];
              return ListTile(
                title: Text('${classData['className']} - Section ${classData['section']}'),
                selected: classData['_id'] == _selectedClassId,
                onTap: () => Navigator.pop(context, classData),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedClassId = selected['_id'];
        _selectedClassName = '${selected['className']} - Section ${selected['section']}';
        _attendanceStatus.clear();
      });
      await _loadStudents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // White container with class, date, and stats
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Class and Date Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Class selector
                          InkWell(
                            onTap: _selectClass,
                            child: Row(
                              children: [
                                const Icon(Icons.school, color: Color(0xFF9C27B0), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedClassName ?? 'Grade 5 - Section A',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 20),
                              ],
                            ),
                          ),
                          // Date selector
                          InkWell(
                            onTap: _selectDate,
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFF9C27B0), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM dd,\nyyyy').format(_selectedDate),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Attendance stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              count: _presentCount,
                              label: 'Present',
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              count: _absentCount,
                              label: 'Absent',
                              color: const Color(0xFFF44336),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              count: _lateCount,
                              label: 'Late',
                              color: const Color(0xFFFF9800),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Student List Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Student List (${_students.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: _markAllPresent,
                        child: const Text(
                          'Mark All Present',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Student List
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: _students.isEmpty
                        ? const Center(
                            child: Text(
                              'No students found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _students.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final student = _students[index];
                              final studentId = student['_id'];
                              final status = _attendanceStatus[studentId] ?? 'present';
                              
                              return _buildStudentCard(student, studentId, status);
                            },
                          ),
                  ),
                ),
                // Save Button
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submitAttendance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9C27B0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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

  Widget _buildStatCard({required int count, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, String studentId, String status) {
    final name = student['name'] ?? 'Unknown';
    final rollNo = student['rollNumber'] ?? 'N/A';
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE1BEE7),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'S',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9C27B0),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Roll No
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Roll No: $rollNo',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusButton(
                studentId: studentId,
                currentStatus: status,
                targetStatus: 'present',
                icon: Icons.check,
                color: const Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              _buildStatusButton(
                studentId: studentId,
                currentStatus: status,
                targetStatus: 'absent',
                icon: Icons.close,
                color: const Color(0xFFF44336),
              ),
              const SizedBox(width: 8),
              _buildStatusButton(
                studentId: studentId,
                currentStatus: status,
                targetStatus: 'late',
                icon: Icons.access_time,
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required String studentId,
    required String currentStatus,
    required String targetStatus,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = currentStatus == targetStatus;
    
    return InkWell(
      onTap: () => _setAttendanceStatus(studentId, targetStatus),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }
}
