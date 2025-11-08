import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({Key? key}) : super(key: key);

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen>
    with SingleTickerProviderStateMixin {
  late ApiService _apiService;
  late TabController _tabController;

  List<dynamic> _classes = [];
  List<dynamic> _subjects = [];
  List<dynamic> _teachers = [];
  List<dynamic> _timetable = [];

  String? _selectedClassId;
  String? _selectedTeacherId;
  String _selectedAcademicYear = '2024-2025';
  String _viewMode = 'class';

  bool _isLoading = true;

  final List<String> _fullDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _shortDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  final List<Map<String, String>> _timeSlots = [
    {'start': '10:00', 'end': '10:40'},
    {'start': '10:40', 'end': '11:20'},
    {'start': '11:20', 'end': '12:00'},
    {'start': '12:30', 'end': '13:10'},
    {'start': '13:10', 'end': '13:50'},
    {'start': '13:50', 'end': '14:30'},
    {'start': '14:30', 'end': '15:00'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _viewMode = _tabController.index == 0 ? 'class' : 'teacher';
        });
        _loadTimetable();
      }
    });
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storageService = StorageService();
    await storageService.init();
    _apiService = ApiService(storageService);
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
      final classesResponse = await _apiService.getClasses();
      final subjectsResponse = await _apiService.getSubjects();
      final teachersResponse = await _apiService.getUsers(role: 'teacher');

      print('Classes response: $classesResponse');
      print('Subjects response: $subjectsResponse');
      print('Teachers response: $teachersResponse');

      setState(() {
        _classes = (classesResponse['data']?['classes'] as List<dynamic>?) ?? [];
        _subjects = (subjectsResponse['data']?['subjects'] as List<dynamic>?) ?? [];
        _teachers = (teachersResponse['data']?['users'] as List<dynamic>?) ?? [];

        print('Loaded ${_classes.length} classes');
        print('Loaded ${_subjects.length} subjects');
        print('Loaded ${_teachers.length} teachers');

        if (_classes.isNotEmpty) {
          _selectedClassId = _classes[0]['_id'];
        }
        if (_teachers.isNotEmpty) {
          _selectedTeacherId = _teachers[0]['_id'];
        }
      });

      await _loadTimetable();
    } catch (e) {
      print('Error loading initial data: $e');
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimetable() async {
    try {
      final Map<String, dynamic> queryParams = {
        'academicYear': _selectedAcademicYear,
      };

      if (_viewMode == 'class' && _selectedClassId != null) {
        queryParams['classId'] = _selectedClassId!;
      }
      if (_viewMode == 'teacher' && _selectedTeacherId != null) {
        queryParams['teacherId'] = _selectedTeacherId!;
      }

      print('Loading timetable with params: $queryParams');

      final response = await _apiService.get(
        '/admin/timetable',
        queryParameters: queryParams,
      );

      print('Timetable response: ${response.data}');

      setState(() {
        _timetable = response.data['data']['timetable'] ?? [];
        print('Loaded ${_timetable.length} timetable entries');
      });
    } catch (e) {
      print('Error loading timetable: $e');
      _showError('Failed to load timetable: $e');
    }
  }

  Map<String, dynamic>? _getTimetableEntry(String day, String startTime) {
    try {
      return _timetable.firstWhere(
        (entry) => entry['dayOfWeek'] == day && entry['startTime'] == startTime,
      );
    } catch (e) {
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Timetable Management')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Timetable Management'),
        backgroundColor: Color(AppColors.primary),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Class View'),
            Tab(text: 'Teacher View'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildClassView(),
          _buildTeacherView(),
        ],
      ),
    );
  }

  Widget _buildClassView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            children: [
              // Class Dropdown
              DropdownButtonFormField<String>(
                value: _selectedClassId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                items: _classes.isEmpty
                    ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No classes available'),
                        )
                      ]
                    : _classes.map<DropdownMenuItem<String>>((cls) {
                        return DropdownMenuItem(
                          value: cls['_id'],
                          child: Text('${cls['className']} ${cls['section']}'),
                        );
                      }).toList(),
                onChanged: _classes.isEmpty
                    ? null
                    : (value) {
                        setState(() => _selectedClassId = value);
                        _loadTimetable();
                      },
              ),
              const SizedBox(height: 8),
              // Academic Year Dropdown
              DropdownButtonFormField<String>(
                value: _selectedAcademicYear,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
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
            ],
          ),
        ),
        Expanded(
          child: _timetable.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _classes.isEmpty
                            ? 'No classes available.\nPlease add classes first.'
                            : 'No timetable data available for this class.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      dataRowHeight: 54,
                      headingRowHeight: 48,
                      border: TableBorder.all(color: Colors.grey[300]!),
                      headingRowColor: MaterialStateProperty.all(
                        Color(AppColors.primary).withOpacity(0.2),
                      ),
                      columns: [
                        const DataColumn(
                            label: Text('Time',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        ..._shortDays.asMap().entries.map((entry) {
                          final index = entry.key;
                          final day = entry.value;
                          return DataColumn(
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _fullDays[index],
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      rows: [
                        ..._timeSlots.take(3).map((slot) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slot['start']!,
                                      style: const TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      slot['end']!,
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              ..._fullDays.map((day) {
                                final entry = _getTimetableEntry(day, slot['start']!);
                                return DataCell(
                                  entry != null
                                      ? _buildTimetableCell(entry)
                                      : _buildEmptyCell(),
                                );
                              }),
                            ],
                          );
                        }),
                        DataRow(
                          color: MaterialStateProperty.all(Colors.amber[50]),
                          cells: [
                            const DataCell(
                              Center(
                                child: Text(
                                  'LUNCH\n12:00-12:30',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            ..._fullDays.map((day) => const DataCell(
                                  Center(
                                    child: Text(
                                      '🍽️',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        ..._timeSlots.skip(3).map((slot) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slot['start']!,
                                      style: const TextStyle(
                                          fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      slot['end']!,
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              ..._fullDays.map((day) {
                                final entry = _getTimetableEntry(day, slot['start']!);
                                return DataCell(
                                  entry != null
                                      ? _buildTimetableCell(entry)
                                      : _buildEmptyCell(),
                                );
                              }),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTeacherView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Column(
            children: [
              // Teacher Dropdown
              DropdownButtonFormField<String>(
                value: _selectedTeacherId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Teacher',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
                ),
                items: _teachers.isEmpty
                    ? [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No teachers available'),
                        )
                      ]
                    : _teachers.map<DropdownMenuItem<String>>((teacher) {
                        return DropdownMenuItem(
                          value: teacher['_id'],
                          child: Text(
                              teacher['profile']?['name'] ?? teacher['email']),
                        );
                      }).toList(),
                onChanged: _teachers.isEmpty
                    ? null
                    : (value) {
                        setState(() => _selectedTeacherId = value);
                        _loadTimetable();
                      },
              ),
              const SizedBox(height: 8),
              // Academic Year Dropdown
              DropdownButtonFormField<String>(
                value: _selectedAcademicYear,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  isDense: true,
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
            ],
          ),
        ),
        Expanded(
          child: _timetable.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        _teachers.isEmpty
                            ? 'No teachers available.\nPlease add teachers first.'
                            : 'No timetable data available for this teacher.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      dataRowHeight: 54,
                      headingRowHeight: 48,
                      border: TableBorder.all(color: Colors.grey[300]!),
                      headingRowColor: MaterialStateProperty.all(
                        Color(AppColors.primary).withOpacity(0.2),
                      ),
                      columns: [
                        const DataColumn(
                            label: Text('Time',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        ..._shortDays.asMap().entries.map((entry) {
                          final index = entry.key;
                          final day = entry.value;
                          return DataColumn(
                            label: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _fullDays[index],
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      rows: _timeSlots.map((slot) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot['start']!,
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    slot['end']!,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            ..._fullDays.map((day) {
                              final entry = _getTimetableEntry(day, slot['start']!);
                              return DataCell(
                                entry != null
                                    ? _buildTimetableCell(entry)
                                    : _buildEmptyCell(),
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
    );
  }

  Widget _buildTimetableCell(Map<String, dynamic> entry) {
    return InkWell(
      onTap: () => _editTimetableEntry(entry),
      child: Container(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 90,
          maxWidth: 120,
          minHeight: 45,
          maxHeight: 50,
        ),
        decoration: BoxDecoration(
          color: Color(AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              entry['subjectId']?['name'] ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            Text(
              _viewMode == 'class'
                  ? (entry['teacherId']?['profile']?['name'] ?? 'N/A')
                  : '${entry['classId']?['className'] ?? 'N/A'} ${entry['classId']?['section'] ?? ''}',
              style: TextStyle(fontSize: 8, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (entry['room'] != null)
              Text(
                'R:${entry['room']}',
                style: TextStyle(fontSize: 7, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCell() {
    return InkWell(
      onTap: () => _addTimetableEntry(),
      child: Container(
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          minWidth: 90,
          maxWidth: 120,
          minHeight: 45,
          maxHeight: 50,
        ),
        child: Center(
          child: Icon(
            Icons.add_circle_outline,
            color: Colors.grey[400],
            size: 14,
          ),
        ),
      ),
    );
  }

  void _editTimetableEntry(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => _TimetableEntryDialog(
        apiService: _apiService,
        entry: entry,
        classes: _classes,
        subjects: _subjects,
        teachers: _teachers,
        viewMode: _viewMode,
        onSaved: () {
          _loadTimetable();
        },
      ),
    );
  }

  void _addTimetableEntry() {
    showDialog(
      context: context,
      builder: (context) => _TimetableEntryDialog(
        apiService: _apiService,
        classes: _classes,
        subjects: _subjects,
        teachers: _teachers,
        viewMode: _viewMode,
        onSaved: () {
          _loadTimetable();
        },
      ),
    );
  }
}

// Dialog for adding/editing timetable entries
class _TimetableEntryDialog extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic>? entry;
  final List<dynamic> classes;
  final List<dynamic> subjects;
  final List<dynamic> teachers;
  final String viewMode;
  final VoidCallback onSaved;

  const _TimetableEntryDialog({
    required this.apiService,
    this.entry,
    required this.classes,
    required this.subjects,
    required this.teachers,
    required this.viewMode,
    required this.onSaved,
  });

  @override
  State<_TimetableEntryDialog> createState() => _TimetableEntryDialogState();
}

class _TimetableEntryDialogState extends State<_TimetableEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClassId;
  String? _selectedSubjectId;
  String? _selectedTeacherId;
  String? _selectedDay;
  String? _startTime;
  String? _endTime;
  String? _room;
  String _academicYear = '2024-2025';
  bool _isLoading = false;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday'
  ];

  final List<Map<String, String>> _timeSlots = [
    {'start': '10:00', 'end': '10:40'},
    {'start': '10:40', 'end': '11:20'},
    {'start': '11:20', 'end': '12:00'},
    {'start': '12:30', 'end': '13:10'},
    {'start': '13:10', 'end': '13:50'},
    {'start': '13:50', 'end': '14:30'},
    {'start': '14:30', 'end': '15:00'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _selectedClassId = widget.entry!['classId']?['_id'];
      _selectedSubjectId = widget.entry!['subjectId']?['_id'];
      _selectedTeacherId = widget.entry!['teacherId']?['_id'];
      _selectedDay = widget.entry!['dayOfWeek'];
      _startTime = widget.entry!['startTime'];
      _endTime = widget.entry!['endTime'];
      _room = widget.entry!['room'];
      _academicYear = widget.entry!['academicYear'] ?? '2024-2025';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'classId': _selectedClassId,
        'subjectId': _selectedSubjectId,
        'teacherId': _selectedTeacherId,
        'dayOfWeek': _selectedDay,
        'startTime': _startTime,
        'endTime': _endTime,
        'room': _room,
        'academicYear': _academicYear,
      };

      if (widget.entry != null) {
        // Update existing entry
        await widget.apiService.put(
          '/admin/timetable/${widget.entry!['_id']}',
          data: data,
        );
      } else {
        // Create new entry
        await widget.apiService.post(
          '/admin/timetable',
          data: data,
        );
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (widget.entry == null) return;

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
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await widget.apiService.delete('/admin/timetable/${widget.entry!['_id']}');
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.entry != null ? 'Edit Timetable' : 'Add Timetable'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedClassId,
                decoration: const InputDecoration(labelText: 'Class'),
                items: widget.classes.map((cls) {
                  return DropdownMenuItem<String>(
                    value: cls['_id'] as String,
                    child: Text('${cls['className']} ${cls['section']}'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedClassId = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedSubjectId,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: widget.subjects.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject['_id'] as String,
                    child: Text(subject['name'] as String),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSubjectId = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedTeacherId,
                decoration: const InputDecoration(labelText: 'Teacher'),
                items: widget.teachers.map((teacher) {
                  return DropdownMenuItem<String>(
                    value: teacher['_id'] as String,
                    child: Text(teacher['profile']?['name'] ?? teacher['email']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTeacherId = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDay,
                decoration: const InputDecoration(labelText: 'Day'),
                items: _days.map((day) {
                  return DropdownMenuItem(value: day, child: Text(day));
                }).toList(),
                onChanged: (value) => setState(() => _selectedDay = value),
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _startTime,
                      decoration: const InputDecoration(labelText: 'Start Time'),
                      items: _timeSlots.map((slot) {
                        return DropdownMenuItem(
                          value: slot['start'],
                          child: Text(slot['start']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _startTime = value;
                          if (value != null) {
                            final slot = _timeSlots.firstWhere(
                              (s) => s['start'] == value,
                              orElse: () => {'start': value, 'end': value},
                            );
                            _endTime = slot['end'];
                          }
                        });
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _endTime,
                      decoration: const InputDecoration(labelText: 'End Time'),
                      enabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _room,
                decoration: const InputDecoration(labelText: 'Room (Optional)'),
                onChanged: (value) => _room = value.isEmpty ? null : value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.entry != null)
          TextButton(
            onPressed: _isLoading ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
