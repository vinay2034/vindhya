import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';

class TimetableOverviewScreen extends StatefulWidget {
  const TimetableOverviewScreen({super.key});

  @override
  State<TimetableOverviewScreen> createState() => _TimetableOverviewScreenState();
}

class _TimetableOverviewScreenState extends State<TimetableOverviewScreen> {
  final ApiService _apiService = getIt<ApiService>();

  List<dynamic> _classes = [];
  List<dynamic> _subjects = [];
  List<dynamic> _teachers = [];
  List<dynamic> _timetable = [];
  
  String _selectedGrade = 'Grade 10';
  String _selectedView = 'Day View';
  String _selectedDay = 'Tue';
  
  bool _isLoading = true;
  int _conflictCount = 2;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  
  final List<String> _grades = [
    'Grade 10',
    'Grade 9',
    'Grade 8',
    'Grade 7',
    'Grade 6',
  ];

  final List<String> _viewModes = ['Day View', 'Week View'];

  // Class sections for Grade 10
  final List<String> _sections = ['Class 10-A', 'Class 10-B', 'Class 10-C'];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.get('/admin/classes'),
        _apiService.get('/admin/subjects'),
        _apiService.get('/admin/users', queryParameters: {'role': 'teacher'}),
      ]);

      setState(() {
        _classes = results[0].data['data']['classes'] ?? [];
        _subjects = results[1].data['data']['subjects'] ?? [];
        _teachers = results[2].data['data']['users'] ?? [];
      });

      await _loadTimetable();
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimetable() async {
    try {
      final response = await _apiService.get('/admin/timetable');
      setState(() {
        _timetable = response.data['data']['timetable'] ?? [];
        _calculateConflicts();
      });
    } catch (e) {
      _showError('Failed to load timetable: $e');
    }
  }

  void _calculateConflicts() {
    // Check for scheduling conflicts (same teacher, same time, different classes)
    _conflictCount = 0;
    for (var i = 0; i < _timetable.length; i++) {
      for (var j = i + 1; j < _timetable.length; j++) {
        final entry1 = _timetable[i];
        final entry2 = _timetable[j];
        
        if (entry1['teacherId']?['_id'] == entry2['teacherId']?['_id'] &&
            entry1['dayOfWeek'] == entry2['dayOfWeek'] &&
            entry1['startTime'] == entry2['startTime']) {
          _conflictCount++;
        }
      }
    }
  }

  List<Map<String, dynamic>> _getTimetableForSection(String section, String day) {
    final filtered = _timetable.where((entry) {
      final className = entry['classId']?['className'] ?? '';
      final sectionName = entry['classId']?['section'] ?? '';
      final fullName = '$className-$sectionName';
      final dayOfWeek = _getDayFullName(day);
      
      return fullName == section && entry['dayOfWeek'] == dayOfWeek;
    }).toList();
    
    final result = filtered.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    result.sort((a, b) {
      final timeA = a['startTime'] ?? '';
      final timeB = b['startTime'] ?? '';
      return timeA.compareTo(timeB);
    });
    
    return result;
  }

  String _getDayFullName(String shortDay) {
    const dayMap = {
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
      'Sat': 'Saturday',
    };
    return dayMap[shortDay] ?? shortDay;
  }

  void _showAddSlotDialog() {
    String? selectedSection;
    String? selectedSubject;
    String? selectedTeacher;
    String selectedDay = _selectedDay;
    String startTime = '09:00';
    String endTime = '10:00';
    String room = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Time Slot'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedSection,
                  decoration: const InputDecoration(
                    labelText: 'Select Section',
                    border: OutlineInputBorder(),
                  ),
                  items: _sections.map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text(section),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedSection = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedSubject,
                  decoration: const InputDecoration(
                    labelText: 'Select Subject',
                    border: OutlineInputBorder(),
                  ),
                  items: _subjects.map<DropdownMenuItem<String>>((subject) {
                    return DropdownMenuItem(
                      value: subject['_id'],
                      child: Text(subject['name'] ?? 'N/A'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedSubject = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedTeacher,
                  decoration: const InputDecoration(
                    labelText: 'Select Teacher',
                    border: OutlineInputBorder(),
                  ),
                  items: _teachers.map<DropdownMenuItem<String>>((teacher) {
                    return DropdownMenuItem(
                      value: teacher['_id'],
                      child: Text(teacher['profile']?['name'] ?? teacher['email']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedTeacher = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    border: OutlineInputBorder(),
                  ),
                  items: _days.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedDay = value!);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: startTime,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          border: OutlineInputBorder(),
                          hintText: 'HH:MM',
                        ),
                        onChanged: (value) => startTime = value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        initialValue: endTime,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          border: OutlineInputBorder(),
                          hintText: 'HH:MM',
                        ),
                        onChanged: (value) => endTime = value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: room,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => room = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedSection == null || selectedSubject == null || selectedTeacher == null) {
                  _showError('Please fill all required fields');
                  return;
                }

                // Parse section to get class and section
                final parts = selectedSection!.split('-');
                final className = parts[0].replaceAll('Class ', '');
                final section = parts[1];

                // Find the class ID
                final classData = _classes.firstWhere(
                  (cls) => cls['className'] == className && cls['section'] == section,
                  orElse: () => null,
                );

                if (classData == null) {
                  _showError('Class not found');
                  return;
                }

                final data = {
                  'classId': classData['_id'],
                  'subjectId': selectedSubject,
                  'teacherId': selectedTeacher,
                  'dayOfWeek': _getDayFullName(selectedDay),
                  'startTime': startTime,
                  'endTime': endTime,
                  'room': room.isEmpty ? null : room,
                  'academicYear': '2024-2025',
                };

                try {
                  await _apiService.post('/admin/timetable', data: data);
                  Navigator.pop(context);
                  _loadTimetable();
                  _showSuccess('Time slot added successfully');
                } catch (e) {
                  _showError('Failed to add slot: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA78FC),
              ),
              child: const Text('Add Slot'),
            ),
          ],
        ),
      ),
    );
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
        title: const Text('Timetable Overview'),
        backgroundColor: const Color(0xFFBA78FC),
        elevation: 0,
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
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBA78FC)),
              ),
            )
          : Column(
              children: [
                // Header Info Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedGrade,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Timetable for sections A, B, C. Last updated: Jul 14.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red[700],
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_conflictCount Conflicts',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
                // Filter Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Grade Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGrade,
                              isExpanded: true,
                              items: _grades.map((grade) {
                                return DropdownMenuItem(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedGrade = value!);
                                _loadTimetable();
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // View Filter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedView,
                              isExpanded: true,
                              items: _viewModes.map((mode) {
                                return DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedView = value!);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Day Selector
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _days.length,
                    itemBuilder: (context, index) {
                      final day = _days[index];
                      final isSelected = day == _selectedDay;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDay = day);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFBA78FC)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Timetable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Column Headers
                      Row(
                        children: [
                          const SizedBox(width: 70),
                          ..._sections.map((section) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  section,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Time Slots
                      _buildTimeSlotRow('09:00', _sections),
                      const SizedBox(height: 12),
                      _buildTimeSlotRow('10:00', _sections),
                      const SizedBox(height: 12),
                      _buildTimeSlotRow('11:00', _sections),
                      const SizedBox(height: 12),
                      _buildTimeSlotRow('12:00', _sections),
                      const SizedBox(height: 12),
                      // Lunch Break
                      Row(
                        children: [
                          const SizedBox(width: 70),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBA78FC).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Lunch Break',
                                  style: TextStyle(
                                    color: Color(0xFFBA78FC),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSlotDialog,
        backgroundColor: const Color(0xFFBA78FC),
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTimeSlotRow(String time, List<String> sections) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Label
        SizedBox(
          width: 70,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        // Classes for each section
        ...sections.map((section) {
          final entries = _getTimetableForSection(section, _selectedDay);
          final entry = entries.firstWhere(
            (e) => e['startTime'] == time,
            orElse: () => {},
          );

          if (entry.isEmpty) {
            return Expanded(
              child: GestureDetector(
                onTap: _showAddSlotDialog,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add_circle_outline,
                      color: const Color(0xFFBA78FC).withOpacity(0.3),
                      size: 24,
                    ),
                  ),
                ),
              ),
            );
          }

          return Expanded(
            child: _buildClassCard(entry),
          );
        }),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> entry) {
    final subjectName = entry['subjectId']?['name'] ?? 'N/A';
    final teacherName = entry['teacherId']?['profile']?['name'] ?? 'N/A';
    final room = entry['room'] ?? 'N/A';
    
    // Check for conflicts - same teacher, same time, different class
    final hasConflict = _timetable.any((other) {
      if (other['_id'] == entry['_id']) return false;
      return other['teacherId']?['_id'] == entry['teacherId']?['_id'] &&
          other['dayOfWeek'] == entry['dayOfWeek'] &&
          other['startTime'] == entry['startTime'];
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasConflict ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasConflict ? Colors.red[300]! : Colors.grey[200]!,
          width: hasConflict ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subjectName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: hasConflict ? Colors.red[700] : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasConflict)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            teacherName,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Room $room',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
          if (hasConflict) ...[
            const SizedBox(height: 4),
            Text(
              'Conflict: Lab A',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
