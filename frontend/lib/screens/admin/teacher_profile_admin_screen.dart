import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class TeacherProfileAdminScreen extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const TeacherProfileAdminScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherProfileAdminScreen> createState() => _TeacherProfileAdminScreenState();
}

class _TeacherProfileAdminScreenState extends State<TeacherProfileAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Teacher\'s Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 5,
        child: Column(
          children: [
            // Profile Header
            Container(
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  // Profile Photo
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(AppColors.primary).withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(AppColors.primary).withOpacity(0.1),
                      child: widget.teacher['photo'] != null
                          ? ClipOval(
                              child: Image.network(
                                widget.teacher['photo'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Color(AppColors.primary),
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Color(AppColors.primary),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Teacher Name
                  Text(
                    widget.teacher['profile']?['name'] ?? widget.teacher['name'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Designation
                  Text(
                    widget.teacher['profile']?['designation'] ?? 'Senior Teacher',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Teacher ID
                  Text(
                    'ID: ${widget.teacher['employeeId'] ?? widget.teacher['_id']?.toString().substring(0, 8).toUpperCase() ?? 'N/A'}',
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
                          onPressed: () {
                            // Make a call
                            final phone = widget.teacher['profile']?['phone'];
                            if (phone != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Calling $phone...')),
                              );
                            }
                          },
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text(
                            'Call',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Send message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Messaging feature coming soon!')),
                            );
                          },
                          icon: const Icon(Icons.message, size: 18),
                          label: const Text(
                            'Message',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(AppColors.primary),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: Color(AppColors.primary).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                isScrollable: true,
                labelColor: Color(AppColors.primary),
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Color(AppColors.primary),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                indicatorSize: TabBarIndicatorSize.label,
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
                children: [
                  _buildPersonalDetailsTab(),
                  _buildClassesTab(),
                  _buildTimetableTab(),
                  _buildAttendanceTab(),
                  _buildChangePasswordTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Contact Information Section
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Color(AppColors.primary),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildInfoItem(
          Icons.phone,
          'Phone',
          widget.teacher['profile']?['phone'] ?? '+91 98765 43210',
        ),
        _buildInfoItem(
          Icons.email_outlined,
          'Email',
          widget.teacher['email'] ?? 'teacher@schoolname.edu',
        ),
        _buildInfoItem(
          Icons.home_outlined,
          'Address',
          widget.teacher['profile']?['address'] ?? '#123, Maple Street, Bengaluru, KA 560001',
        ),

        const SizedBox(height: 24),

        // Personal Information Section
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Color(AppColors.primary),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildInfoItem(
          Icons.cake_outlined,
          'Date of Birth',
          widget.teacher['profile']?['dateOfBirth'] ?? '15th August, 1985',
        ),
        _buildInfoItem(
          Icons.calendar_today_outlined,
          'Date of Joining',
          widget.teacher['profile']?['joiningDate'] ?? '1st June, 2010',
        ),
        _buildInfoItem(
          Icons.contact_emergency_outlined,
          'Emergency Contact',
          widget.teacher['profile']?['emergencyContact'] ?? 'Anil Sharma (Spouse) - +91 98765 11223',
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              color: Color(AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Color(AppColors.primary),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
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
    // Mock classes data
    final List<Map<String, dynamic>> classes = [
      {'name': 'Class 10 - Section A', 'subject': 'Mathematics', 'students': 35},
      {'name': 'Class 9 - Section B', 'subject': 'Mathematics', 'students': 32},
      {'name': 'Class 8 - Section A', 'subject': 'Mathematics', 'students': 30},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Color(AppColors.primary),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Assigned Classes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...classes.map((classInfo) => _buildClassCard(classInfo)).toList(),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> classInfo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
              color: Color(AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.class_outlined,
              color: Color(AppColors.primary),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classInfo['name'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  classInfo['subject'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${classInfo['students']}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primary),
                ),
              ),
              Text(
                'Students',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableTab() {
    // Mock timetable data
    final List<Map<String, dynamic>> schedule = [
      {
        'day': 'Monday',
        'periods': [
          {'time': '9:00 - 10:00', 'class': 'Class 10-A', 'subject': 'Maths'},
          {'time': '11:00 - 12:00', 'class': 'Class 9-B', 'subject': 'Maths'},
        ],
      },
      {
        'day': 'Tuesday',
        'periods': [
          {'time': '10:00 - 11:00', 'class': 'Class 8-A', 'subject': 'Maths'},
          {'time': '2:00 - 3:00', 'class': 'Class 10-A', 'subject': 'Maths'},
        ],
      },
      {
        'day': 'Wednesday',
        'periods': [
          {'time': '9:00 - 10:00', 'class': 'Class 9-B', 'subject': 'Maths'},
          {'time': '11:00 - 12:00', 'class': 'Class 10-A', 'subject': 'Maths'},
        ],
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Color(AppColors.primary),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Weekly Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ...schedule.map((day) => _buildDaySchedule(day)).toList(),
      ],
    );
  }

  Widget _buildDaySchedule(Map<String, dynamic> day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
              color: Color(AppColors.primary).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Color(AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  day['day'],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          ...((day['periods'] as List).map((period) => _buildPeriodItem(period)).toList()),
        ],
      ),
    );
  }

  Widget _buildPeriodItem(Map<String, dynamic> period) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  period['time'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period['class'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  period['subject'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    // Mock attendance data - in real app, fetch from API
    final attendanceRecords = [
      {
        'date': '2024-11-08',
        'status': 'Present',
        'checkIn': '08:45 AM',
        'checkOut': '04:30 PM',
        'hours': '7.75',
      },
      {
        'date': '2024-11-07',
        'status': 'Present',
        'checkIn': '08:50 AM',
        'checkOut': '04:25 PM',
        'hours': '7.58',
      },
      {
        'date': '2024-11-06',
        'status': 'Present',
        'checkIn': '08:42 AM',
        'checkOut': '04:35 PM',
        'hours': '7.88',
      },
      {
        'date': '2024-11-05',
        'status': 'Leave',
        'checkIn': '-',
        'checkOut': '-',
        'hours': '0',
      },
      {
        'date': '2024-11-04',
        'status': 'Present',
        'checkIn': '08:55 AM',
        'checkOut': '04:20 PM',
        'hours': '7.42',
      },
      {
        'date': '2024-11-01',
        'status': 'Present',
        'checkIn': '08:48 AM',
        'checkOut': '04:28 PM',
        'hours': '7.67',
      },
      {
        'date': '2024-10-31',
        'status': 'Absent',
        'checkIn': '-',
        'checkOut': '-',
        'hours': '0',
      },
      {
        'date': '2024-10-30',
        'status': 'Present',
        'checkIn': '08:52 AM',
        'checkOut': '04:32 PM',
        'hours': '7.67',
      },
    ];

    // Calculate statistics
    final totalDays = attendanceRecords.length;
    final presentDays = attendanceRecords.where((r) => r['status'] == 'Present').length;
    final leaveDays = attendanceRecords.where((r) => r['status'] == 'Leave').length;
    final absentDays = attendanceRecords.where((r) => r['status'] == 'Absent').length;
    final attendancePercentage = ((presentDays / totalDays) * 100).toStringAsFixed(1);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Statistics Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Present',
                presentDays.toString(),
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Leave',
                leaveDays.toString(),
                Colors.orange,
                Icons.event_busy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Absent',
                absentDays.toString(),
                Colors.red,
                Icons.cancel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Attendance Percentage Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(AppColors.primary), Color(AppColors.primary).withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(AppColors.primary).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Rate',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$attendancePercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Out of $totalDays days',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Attendance Records Header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Color(AppColors.primary),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Attendance Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Attendance Records List
        ...attendanceRecords.map((record) => _buildAttendanceCard(record)).toList(),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
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
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
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
      case 'Absent':
        statusColor = Colors.red;
        bgColor = Colors.red[50]!;
        statusIcon = Icons.cancel;
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
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    record['date'].split('-')[2],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    _getMonthName(record['date'].split('-')[1]),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        record['status'],
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
                    Wrap(
                      spacing: 12,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.login, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 3),
                            Text(
                              record['checkIn'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 3),
                            const SizedBox(width: 3),
                            Text(
                              record['checkOut'],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      record['hours'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primary),
                      ),
                    ),
                    Text(
                      'hrs',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(String month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[int.parse(month) - 1];
  }

  Widget _buildChangePasswordTab() {
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.white, size: 22),
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

              // New Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        'New Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.lock, color: Color(AppColors.primary)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            'Password must be at least 6 characters',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Password Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        'Confirm New Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Re-enter new password',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.lock_outline, color: Color(AppColors.primary)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Change Password Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [
                      Color(AppColors.primary),
                      Color(AppColors.primary).withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(AppColors.primary).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Validate passwords
                    if (_newPasswordController.text.isEmpty ||
                        _confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (_newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password must be at least 6 characters'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (_newPasswordController.text != _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Passwords do not match'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // TODO: Call API to change password
                    // For now, show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Clear fields
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
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
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
