import 'package:flutter/material.dart';
import 'edit_teacher_screen.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';

class TeacherProfileAdminView extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const TeacherProfileAdminView({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherProfileAdminView> createState() =>
      _TeacherProfileAdminViewState();
}

class _TeacherProfileAdminViewState extends State<TeacherProfileAdminView>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = getIt<ApiService>();
  late TabController _tabController;
  
  List<Map<String, dynamic>> _assignedClasses = [];
  List<Map<String, dynamic>> _timetable = [];
  bool _isLoadingClasses = true;
  bool _isLoadingTimetable = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    await Future.wait([
      _loadAssignedClasses(),
      _loadTimetable(),
    ]);
  }

  Future<void> _loadAssignedClasses() async {
    try {
      final teacherId = widget.teacher['_id'];
      // Fetch classes assigned to this teacher from timetable
      final response = await _apiService.get(
        '/admin/timetable',
        queryParameters: {'teacherId': teacherId},
      );
      
      print('Classes response: ${response.data}');
      
      if (response.data['status'] == 'success') {
        final timetableData = response.data['data']['timetable'] as List;
        
        // Get unique classes from timetable
        final classesMap = <String, Map<String, dynamic>>{};
        for (var entry in timetableData) {
          final classData = entry['classId'];
          final classId = classData?['_id'];
          
          if (classId != null && !classesMap.containsKey(classId)) {
            classesMap[classId] = {
              'name': classData['className'] ?? '',
              'section': classData['section'] ?? '',
              'subject': entry['subjectId']?['name'] ?? '',
            };
          }
        }
        
        print('Parsed classes: $classesMap');
        
        setState(() {
          _assignedClasses = classesMap.values.toList();
          _isLoadingClasses = false;
        });
      } else {
        setState(() => _isLoadingClasses = false);
      }
    } catch (e) {
      print('Error loading classes: $e');
      setState(() => _isLoadingClasses = false);
    }
  }

  Future<void> _loadTimetable() async {
    try {
      final teacherId = widget.teacher['_id'];
      final response = await _apiService.get(
        '/admin/timetable',
        queryParameters: {'teacherId': teacherId},
      );
      
      print('Timetable response: ${response.data}');
      
      if (response.data['status'] == 'success') {
        final timetableData = response.data['data']['timetable'] as List;
        
        // Group by day and sort by time
        final groupedByDay = <String, List<Map<String, dynamic>>>{};
        
        for (var entry in timetableData) {
          final day = entry['dayOfWeek'] ?? '';
          if (day.isEmpty) continue;
          
          if (!groupedByDay.containsKey(day)) {
            groupedByDay[day] = [];
          }
          
          final classData = entry['classId'];
          final subjectData = entry['subjectId'];
          
          groupedByDay[day]!.add({
            'day': day,
            'startTime': entry['startTime'] ?? '',
            'endTime': entry['endTime'] ?? '',
            'subject': subjectData?['name'] ?? '',
            'class': '${classData?['className'] ?? ''} ${classData?['section'] ?? ''}'.trim(),
            'room': entry['room'] ?? '',
          });
        }
        
        // Sort each day's periods by start time
        groupedByDay.forEach((day, periods) {
          periods.sort((a, b) => a['startTime'].compareTo(b['startTime']));
        });
        
        print('Grouped timetable: $groupedByDay');
        
        setState(() {
          _timetable = groupedByDay.entries
              .map((e) => {
                    'day': e.key,
                    'periods': e.value,
                  })
              .toList();
          _isLoadingTimetable = false;
        });
      } else {
        setState(() => _isLoadingTimetable = false);
      }
    } catch (e) {
      print('Error loading timetable: $e');
      setState(() => _isLoadingTimetable = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teacherName = widget.teacher['profile']?['name'] ??
        widget.teacher['name'] ??
        'Anjali Joshi';
    final designation =
        widget.teacher['profile']?['designation'] ?? 'Senior Teacher';
    final employeeId = widget.teacher['employeeId'] ?? 'EMP0010';
    final phone = widget.teacher['profile']?['phone'];
    final email = widget.teacher['email'];
    final photoUrl = widget.teacher['profile']?['avatar'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Teacher's Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFBA78FC)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTeacherScreen(
                    teacher: widget.teacher,
                  ),
                ),
              );
              
              // Reload profile if changes were saved
              if (result == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please refresh to see updated details'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Column(
              children: [
                // Profile Photo
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFFE1BEE7),
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFFBA78FC),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                // Teacher Name
                Text(
                  teacherName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                  const SizedBox(height: 6),

                // Designation
                Text(
                  designation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),

                // Teacher ID
                Text(
                  'ID: $employeeId',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: phone != null
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Calling $phone...')),
                                );
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text(
                          'Call',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Messaging feature coming soon!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBA78FC),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.message, size: 18),
                        label: const Text(
                          'Message',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFFBA78FC),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFFBA78FC),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Classes'),
                Tab(text: 'Timetable'),
                Tab(text: 'Attendance'),
                Tab(text: 'Password'),
              ],
            ),
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalTab(phone, email),
                _buildClassesTab(),
                _buildTimetableTab(),
                _buildAttendanceTab(),
                _buildPasswordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab(String? phone, String? email) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          Icons.email_outlined,
          'Email',
          email ?? 'N/A',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.phone_outlined,
          'Phone Number',
          phone ?? 'N/A',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.cake_outlined,
          'Date of Birth',
          widget.teacher['profile']?['dateOfBirth'] ?? '15th August, 1985',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.calendar_today_outlined,
          'Date of Joining',
          widget.teacher['profile']?['joiningDate'] ?? '1st June, 2010',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          Icons.home_outlined,
          'Address',
          widget.teacher['profile']?['address'] ??
              '#123, Maple Street, Bengaluru, KA 560001',
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFBA78FC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFBA78FC),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    if (_isLoadingClasses) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_assignedClasses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.class_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No classes assigned to this teacher',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignedClasses.length,
      itemBuilder: (context, index) {
        final classInfo = _assignedClasses[index];
        final className = '${classInfo['name']} - ${classInfo['section']}';
        final subject = classInfo['subject'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA78FC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.class_outlined,
                  color: Color(0xFFBA78FC),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      className,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimetableTab() {
    if (_isLoadingTimetable) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_timetable.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No timetable assigned to this teacher',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Define day order
    final dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    
    // Sort timetable by day order
    _timetable.sort((a, b) {
      final aIndex = dayOrder.indexOf(a['day']);
      final bIndex = dayOrder.indexOf(b['day']);
      return aIndex.compareTo(bIndex);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _timetable.length,
      itemBuilder: (context, index) {
        final dayData = _timetable[index];
        final day = dayData['day'] as String;
        final periods = dayData['periods'] as List<Map<String, dynamic>>;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFBA78FC).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Color(0xFFBA78FC),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBA78FC),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${periods.length} periods',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ...periods.map((period) {
                final time = '${period['startTime']} - ${period['endTime']}';
                final className = period['class'] ?? '';
                final subject = period['subject'] ?? '';
                final room = period['room'] ?? '';
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[100]!),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.access_time,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              className,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subject + (room.isNotEmpty ? ' • Room $room' : ''),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    final attendanceRecords = [
      {
        'date': '08',
        'month': 'Nov',
        'status': 'Present',
        'checkIn': '08:45 AM',
        'checkOut': '04:30 PM',
        'hours': '7.75',
      },
      {
        'date': '07',
        'month': 'Nov',
        'status': 'Present',
        'checkIn': '08:50 AM',
        'checkOut': '04:25 PM',
        'hours': '7.58',
      },
      {
        'date': '06',
        'month': 'Nov',
        'status': 'Present',
        'checkIn': '08:42 AM',
        'checkOut': '04:35 PM',
        'hours': '7.88',
      },
      {
        'date': '05',
        'month': 'Nov',
        'status': 'Leave',
        'checkIn': '',
        'checkOut': '',
        'hours': '0',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: attendanceRecords.length,
      itemBuilder: (context, index) {
        final record = attendanceRecords[index];
        Color statusColor;
        Color bgColor;
        IconData statusIcon;

        switch (record['status']) {
          case 'Present':
            statusColor = Colors.green;
            bgColor = Colors.green[50]!;
            statusIcon = Icons.check_circle;
            break;
          case 'Leave':
            statusColor = Colors.orange;
            bgColor = Colors.orange[50]!;
            statusIcon = Icons.event_busy;
            break;
          default:
            statusColor = Colors.grey;
            bgColor = Colors.grey[50]!;
            statusIcon = Icons.help_outline;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              // Date
              Container(
                width: 55,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      record['date']!,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      record['month']!,
                      style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          record['status']!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (record['status'] == 'Present') ...[
                      Row(
                        children: [
                          Icon(Icons.login, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            record['checkIn']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.logout, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            record['checkOut']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'No check-in/out record',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Hours
              if (record['status'] == 'Present')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA78FC).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        record['hours']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFBA78FC),
                        ),
                      ),
                      const Text(
                        'hrs',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFFBA78FC),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[50]!, Colors.blue[100]!.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Set a new password for this teacher account. The teacher will use the new password for their next login.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[900],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              hintText: 'Enter new password',
              prefixIcon: const Icon(Icons.lock, color: Color(0xFFBA78FC)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBA78FC)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              hintText: 'Re-enter new password',
              prefixIcon:
                  const Icon(Icons.lock_outline, color: Color(0xFFBA78FC)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFBA78FC)),
              ),
            ),
          ),
          const SizedBox(height: 36),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.lock_reset, size: 20),
              label: const Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA78FC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
