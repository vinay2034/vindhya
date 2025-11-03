import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({Key? key}) : super(key: key);

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = getIt<ApiService>();
  late TabController _tabController;

  List<dynamic> _classes = [];
  List<dynamic> _subjects = [];
  List<dynamic> _teachers = [];
  List<dynamic> _timetable = [];
  
  String? _selectedClassId;
  String? _selectedTeacherId;
  String _selectedAcademicYear = '2024-2025';
  
  bool _isLoading = true;
  String _viewMode = 'class'; // 'class' or 'teacher'

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  final List<Map<String, String>> _timeSlots = [
    {'start': '08:00', 'end': '08:45'},
    {'start': '08:45', 'end': '09:30'},
    {'start': '09:30', 'end': '10:15'},
    {'start': '10:30', 'end': '11:15'},
    {'start': '11:15', 'end': '12:00'},
    {'start': '12:00', 'end': '12:45'},
    {'start': '13:30', 'end': '14:15'},
    {'start': '14:15', 'end': '15:00'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _viewMode = _tabController.index == 0 ? 'class' : 'teacher';
          _timetable = [];
        });
        _loadTimetable();
      }
    });
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes[0]['_id'];
        }
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
      final queryParams = {
        'academicYear': _selectedAcademicYear,
        if (_viewMode == 'class' && _selectedClassId != null)
          'classId': _selectedClassId,
        if (_viewMode == 'teacher' && _selectedTeacherId != null)
          'teacherId': _selectedTeacherId,
      };

      final response = await _apiService.get(
        '/admin/timetable',
        queryParameters: queryParams,
      );

      setState(() {
        _timetable = response.data['data']['timetable'] ?? [];
      });
    } catch (e) {
      _showError('Failed to load timetable: $e');
    }
  }

  Map<String, dynamic>? _getTimetableEntry(String day, String startTime) {
    try {
      return _timetable.firstWhere(
        (entry) =>
            entry['dayOfWeek'] == day && entry['startTime'] == startTime,
      );
    } catch (e) {
      return null;
    }
  }

  void _showAddEditDialog({Map<String, dynamic>? entry}) {
    final isEdit = entry != null;
    String? selectedClassId = entry?['classId']?['_id'] ?? _selectedClassId;
    String? selectedSubjectId = entry?['subjectId']?['_id'];
    String? selectedTeacherId = entry?['teacherId']?['_id'];
    String selectedDay = entry?['dayOfWeek'] ?? _days[0];
    String selectedStartTime = entry?['startTime'] ?? _timeSlots[0]['start']!;
    String selectedEndTime = entry?['endTime'] ?? _timeSlots[0]['end']!;
    String room = entry?['room'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Timetable Entry' : 'Add Timetable Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedClassId,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: _classes.map<DropdownMenuItem<String>>((cls) {
                    return DropdownMenuItem(
                      value: cls['_id'],
                      child: Text('${cls['className']} ${cls['section']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedClassId = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSubjectId,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  items: _subjects.map<DropdownMenuItem<String>>((subject) {
                    return DropdownMenuItem(
                      value: subject['_id'],
                      child: Text(subject['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedSubjectId = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTeacherId,
                  decoration: const InputDecoration(labelText: 'Teacher'),
                  items: _teachers.map<DropdownMenuItem<String>>((teacher) {
                    return DropdownMenuItem(
                      value: teacher['_id'],
                      child: Text(teacher['profile']?['name'] ?? teacher['email']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedTeacherId = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
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
                      child: DropdownButtonFormField<String>(
                        value: selectedStartTime,
                        decoration: const InputDecoration(labelText: 'Start Time'),
                        items: _timeSlots.map((slot) {
                          return DropdownMenuItem(
                            value: slot['start'],
                            child: Text(slot['start']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedStartTime = value!;
                            final slotIndex = _timeSlots.indexWhere(
                              (s) => s['start'] == value,
                            );
                            if (slotIndex != -1) {
                              selectedEndTime = _timeSlots[slotIndex]['end']!;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedEndTime,
                        decoration: const InputDecoration(labelText: 'End Time'),
                        items: _timeSlots.map((slot) {
                          return DropdownMenuItem(
                            value: slot['end'],
                            child: Text(slot['end']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedEndTime = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: room,
                  decoration: const InputDecoration(
                    labelText: 'Room (Optional)',
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
                if (selectedClassId == null ||
                    selectedSubjectId == null ||
                    selectedTeacherId == null) {
                  _showError('Please fill all required fields');
                  return;
                }

                final data = {
                  'classId': selectedClassId,
                  'subjectId': selectedSubjectId,
                  'teacherId': selectedTeacherId,
                  'dayOfWeek': selectedDay,
                  'startTime': selectedStartTime,
                  'endTime': selectedEndTime,
                  'room': room.isEmpty ? null : room,
                  'academicYear': _selectedAcademicYear,
                };

                try {
                  if (isEdit) {
                    await _apiService.put(
                      '/admin/timetable/${entry['_id']}',
                      data: data,
                    );
                  } else {
                    await _apiService.post('/admin/timetable', data: data);
                  }

                  Navigator.pop(context);
                  _loadTimetable();
                  _showSuccess(
                    isEdit
                        ? 'Timetable updated successfully'
                        : 'Timetable entry added successfully',
                  );
                } catch (e) {
                  _showError('Operation failed: $e');
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEntry(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this timetable entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.delete('/admin/timetable/$id');
        _loadTimetable();
        _showSuccess('Timetable entry deleted successfully');
      } catch (e) {
        _showError('Failed to delete entry: $e');
      }
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
        title: const Text('Timetable Management'),
        backgroundColor: const Color(0xFFBA78FC),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Class View'),
            Tab(text: 'Teacher View'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Section
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      if (_viewMode == 'class') ...[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedClassId,
                            decoration: const InputDecoration(
                              labelText: 'Select Class',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _classes.map<DropdownMenuItem<String>>((cls) {
                              return DropdownMenuItem(
                                value: cls['_id'],
                                child: Text('${cls['className']} ${cls['section']}'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedClassId = value);
                              _loadTimetable();
                            },
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedTeacherId,
                            decoration: const InputDecoration(
                              labelText: 'Select Teacher',
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            items: _teachers.map<DropdownMenuItem<String>>((teacher) {
                              return DropdownMenuItem(
                                value: teacher['_id'],
                                child: Text(teacher['profile']?['name'] ?? teacher['email']),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedTeacherId = value);
                              _loadTimetable();
                            },
                          ),
                        ),
                      ],
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedAcademicYear,
                          decoration: const InputDecoration(
                            labelText: 'Academic Year',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: ['2024-2025', '2023-2024', '2025-2026']
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedAcademicYear = value!);
                            _loadTimetable();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Timetable Grid
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        border: TableBorder.all(color: Colors.grey[300]!),
                        headingRowColor: MaterialStateProperty.all(
                          const Color(0xFFBA78FC).withOpacity(0.2),
                        ),
                        columns: [
                          const DataColumn(label: Text('Time')),
                          ..._days.map((day) => DataColumn(
                                label: Text(
                                  day,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                        ],
                        rows: _timeSlots.map((slot) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${slot['start']}\n${slot['end']}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              ..._days.map((day) {
                                final entry = _getTimetableEntry(day, slot['start']!);
                                return DataCell(
                                  entry != null
                                      ? _buildTimetableCell(entry)
                                      : _buildEmptyCell(day, slot['start']!),
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFBA78FC),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimetableCell(Map<String, dynamic> entry) {
    return Container(
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 120, minHeight: 80),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry['subjectId']?['name'] ?? 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _viewMode == 'class'
                    ? (entry['teacherId']?['profile']?['name'] ?? 'N/A')
                    : '${entry['classId']?['className']} ${entry['classId']?['section']}',
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry['room'] != null) ...[
                const SizedBox(height: 2),
                Text(
                  'Room: ${entry['room']}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _showAddEditDialog(entry: entry),
                  child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _deleteEntry(entry['_id']),
                  child: const Icon(Icons.delete, size: 16, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCell(String day, String startTime) {
    return InkWell(
      onTap: () {
        // Pre-fill the dialog with this day and time
        _showAddEditDialog();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 120, minHeight: 80),
        child: Center(
          child: Icon(
            Icons.add_circle_outline,
            color: Colors.grey[400],
            size: 20,
          ),
        ),
      ),
    );
  }
}
