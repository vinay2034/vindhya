import 'package:flutter/material.dart';

class TeacherProfileAdminScreen extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const TeacherProfileAdminScreen({
    super.key,
    required this.teacher,
  });



  @override  const TeacherProfileAdminScreen({

  State<TeacherProfileAdminScreen> createState() => _TeacherProfileAdminScreenState();

}    super.key,  const TeacherProfileAdminScreen({



class _TeacherProfileAdminScreenState extends State<TeacherProfileAdminScreen> {    required this.teacher,    super.key,

  @override

  Widget build(BuildContext context) {  });    required this.teacher,

    final teacherName = widget.teacher['profile']?['name'] ?? 

                       widget.teacher['name'] ??   });

                       'Sanjana Sharma';

    final designation = widget.teacher['profile']?['designation'] ??   @override

                       'Senior Maths Teacher';

    final employeeId = widget.teacher['employeeId'] ??   State<TeacherProfileAdminScreen> createState() => _TeacherProfileAdminScreenState();  @override

                      'TCH-0451';

    final phone = widget.teacher['profile']?['phone'];}  State<TeacherProfileAdminScreen> createState() => _TeacherProfileAdminScreenState();

    final email = widget.teacher['email'];

    final photoUrl = widget.teacher['profile']?['avatar'];}



    return Scaffold(class _TeacherProfileAdminScreenState extends State<TeacherProfileAdminScreen> {

      backgroundColor: Colors.white,

      appBar: AppBar(  @overrideclass _TeacherProfileAdminScreenState extends State<TeacherProfileAdminScreen> {

        backgroundColor: Colors.white,

        elevation: 0,  Widget build(BuildContext context) {  @override

        leading: IconButton(

          icon: const Icon(Icons.arrow_back, color: Colors.black),    final teacherName = widget.teacher['profile']?['name'] ??   Widget build(BuildContext context) {

          onPressed: () => Navigator.pop(context),

        ),                       widget.teacher['name'] ??     return Scaffold(

        title: const Text(

          "Teacher's Profile",                       'Sanjana Sharma';      backgroundColor: Colors.grey[50],

          style: TextStyle(

            color: Colors.black,    final designation = widget.teacher['profile']?['designation'] ??       appBar: AppBar(

            fontWeight: FontWeight.w600,

            fontSize: 18,                       'Senior Maths Teacher';        title: const Text('Teacher\'s Profile'),

          ),

        ),    final employeeId = widget.teacher['employeeId'] ??         actions: [

        actions: [

          IconButton(                      'TCH-0451';          IconButton(

            icon: const Icon(Icons.more_vert, color: Colors.black),

            onPressed: () {    final phone = widget.teacher['profile']?['phone'];            icon: const Icon(Icons.more_vert),

              _showMoreOptions(context);

            },    final email = widget.teacher['email'];            onPressed: () {},

          ),

        ],    final photoUrl = widget.teacher['profile']?['avatar'];          ),

      ),

      body: SingleChildScrollView(        ],

        child: Column(

          children: [    return Scaffold(      ),

            // Profile Header Section

            Container(      backgroundColor: Colors.white,      body: DefaultTabController(

              color: Colors.white,

              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),      appBar: AppBar(        length: 5,

              child: Column(

                children: [        backgroundColor: Colors.white,        child: Column(

                  // Profile Photo

                  Container(        elevation: 0,          children: [

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,        leading: IconButton(            // Profile Header

                      boxShadow: [

                        BoxShadow(          icon: const Icon(Icons.arrow_back, color: Colors.black),            Container(

                          color: Colors.black.withOpacity(0.1),

                          blurRadius: 12,          onPressed: () => Navigator.pop(context),              decoration: BoxDecoration(

                          offset: const Offset(0, 4),

                        ),        ),                color: Colors.white,

                      ],

                    ),        title: const Text(                boxShadow: [

                    child: CircleAvatar(

                      radius: 60,          "Teacher's Profile",                  BoxShadow(

                      backgroundColor: const Color(0xFFFFD4B2),

                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,          style: TextStyle(                    color: Colors.black.withOpacity(0.05),

                      child: photoUrl == null

                          ? const Icon(            color: Colors.black,                    blurRadius: 4,

                              Icons.person,

                              size: 60,            fontWeight: FontWeight.w600,                    offset: const Offset(0, 2),

                              color: Colors.white,

                            )            fontSize: 18,                  ),

                          : null,

                    ),          ),                ],

                  ),

                  const SizedBox(height: 20),        ),              ),



                  // Teacher Name        actions: [              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),

                  Text(

                    teacherName,          IconButton(              child: Column(

                    style: const TextStyle(

                      fontSize: 24,            icon: const Icon(Icons.more_vert, color: Colors.black),                children: [

                      fontWeight: FontWeight.bold,

                      color: Colors.black,            onPressed: () {                  // Profile Photo

                    ),

                  ),              _showMoreOptions(context);                  Container(

                  const SizedBox(height: 6),

            },                    decoration: BoxDecoration(

                  // Designation

                  Text(          ),                      shape: BoxShape.circle,

                    designation,

                    style: TextStyle(        ],                      boxShadow: [

                      fontSize: 15,

                      color: Colors.grey[600],      ),                        BoxShadow(

                    ),

                  ),      body: SingleChildScrollView(                          color: const Color(AppColors.primary).withOpacity(0.2),

                  const SizedBox(height: 4),

        child: Column(                          blurRadius: 12,

                  // Teacher ID

                  Text(          children: [                          offset: const Offset(0, 4),

                    'ID: $employeeId',

                    style: TextStyle(            // Profile Header Section                        ),

                      fontSize: 14,

                      color: Colors.grey[500],            Container(                      ],

                    ),

                  ),              color: Colors.white,                    ),

                  const SizedBox(height: 24),

              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),                    child: CircleAvatar(

                  // Action Buttons

                  Row(              child: Column(                      radius: 50,

                    children: [

                      Expanded(                children: [                      backgroundColor: const Color(AppColors.primary).withOpacity(0.1),

                        child: OutlinedButton(

                          onPressed: phone != null                  // Profile Photo                      child: widget.teacher['photo'] != null

                              ? () {

                                  ScaffoldMessenger.of(context).showSnackBar(                  Container(                          ? ClipOval(

                                    SnackBar(content: Text('Calling $phone...')),

                                  );                    decoration: BoxDecoration(                              child: Image.network(

                                }

                              : null,                      shape: BoxShape.circle,                                widget.teacher['photo'],

                          style: OutlinedButton.styleFrom(

                            foregroundColor: Colors.black87,                      boxShadow: [                                width: 100,

                            side: BorderSide(color: Colors.grey[300]!),

                            shape: RoundedRectangleBorder(                        BoxShadow(                                height: 100,

                              borderRadius: BorderRadius.circular(12),

                            ),                          color: Colors.black.withOpacity(0.1),                                fit: BoxFit.cover,

                            padding: const EdgeInsets.symmetric(vertical: 16),

                          ),                          blurRadius: 12,                                errorBuilder: (context, error, stackTrace) {

                          child: const Text(

                            'Call',                          offset: const Offset(0, 4),                                  return const Icon(

                            style: TextStyle(

                              fontSize: 16,                        ),                                    Icons.person,

                              fontWeight: FontWeight.w600,

                            ),                      ],                                    size: 50,

                          ),

                        ),                    ),                                    color: Color(AppColors.primary),

                      ),

                      const SizedBox(width: 12),                    child: CircleAvatar(                                  );

                      Expanded(

                        flex: 2,                      radius: 60,                                },

                        child: ElevatedButton(

                          onPressed: () {                      backgroundColor: const Color(0xFFFFD4B2),                              ),

                            ScaffoldMessenger.of(context).showSnackBar(

                              const SnackBar(                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,                            )

                                content: Text('Messaging feature coming soon!'),

                              ),                      child: photoUrl == null                          : const Icon(

                            );

                          },                          ? const Icon(                              Icons.person,

                          style: ElevatedButton.styleFrom(

                            backgroundColor: const Color(0xFFBA78FC),                              Icons.person,                              size: 50,

                            foregroundColor: Colors.white,

                            elevation: 0,                              size: 60,                              color: Color(AppColors.primary),

                            shape: RoundedRectangleBorder(

                              borderRadius: BorderRadius.circular(12),                              color: Colors.white,                            ),

                            ),

                            padding: const EdgeInsets.symmetric(vertical: 16),                            )                    ),

                          ),

                          child: const Text(                          : null,                  ),

                            'Message',

                            style: TextStyle(                    ),                  const SizedBox(height: 16),

                              fontSize: 16,

                              fontWeight: FontWeight.bold,                  ),

                            ),

                          ),                  const SizedBox(height: 20),                  // Teacher Name

                        ),

                      ),                  Text(

                    ],

                  ),                  // Teacher Name                    widget.teacher['profile']?['name'] ?? widget.teacher['name'] ?? 'N/A',

                ],

              ),                  Text(                    style: const TextStyle(

            ),

                    teacherName,                      fontSize: 22,

            const SizedBox(height: 12),

                    style: const TextStyle(                      fontWeight: FontWeight.bold,

            // Today's Timetable Section

            _buildTimetableSection(),                      fontSize: 24,                      color: Colors.black87,



            const SizedBox(height: 12),                      fontWeight: FontWeight.bold,                    ),



            // Assigned Classes Section                      color: Colors.black,                  ),

            _buildAssignedClassesSection(),

                    ),                  const SizedBox(height: 4),

            const SizedBox(height: 12),

                  ),

            // Contact Information Section

            _buildContactSection(phone, email),                  const SizedBox(height: 6),                  // Designation



            const SizedBox(height: 12),                  Text(



            // Performance Section                  // Designation                    widget.teacher['profile']?['designation'] ?? 'Senior Teacher',

            _buildPerformanceSection(),

                  Text(                    style: TextStyle(

            const SizedBox(height: 24),

          ],                    designation,                      fontSize: 14,

        ),

      ),                    style: TextStyle(                      color: Colors.grey[600],

    );

  }                      fontSize: 15,                    ),



  Widget _buildTimetableSection() {                      color: Colors.grey[600],                  ),

    // Mock today's schedule

    final schedule = [                    ),                  const SizedBox(height: 2),

      {

        'time': '09:00 - 10:00',                  ),

        'subject': 'Math',

        'grade': '10A',                  const SizedBox(height: 4),                  // Teacher ID

        'room': 'Room 201',

      },                  Text(

      {

        'time': '10:00 - 11:00',                  // Teacher ID                    'ID: ${widget.teacher['employeeId'] ?? widget.teacher['_id']?.toString().substring(0, 8).toUpperCase() ?? 'N/A'}',

        'subject': 'Math',

        'grade': '11B',                  Text(                    style: TextStyle(

        'room': 'Room 203',

      },                    'ID: $employeeId',                      fontSize: 13,

    ];

                    style: TextStyle(                      color: Colors.grey[500],

    return Container(

      color: Colors.white,                      fontSize: 14,                    ),

      padding: const EdgeInsets.all(20),

      child: Column(                      color: Colors.grey[500],                  ),

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [                    ),                  const SizedBox(height: 20),

          const Text(

            "Today's Timetable",                  ),

            style: TextStyle(

              fontSize: 18,                  const SizedBox(height: 24),                  // Action Buttons

              fontWeight: FontWeight.bold,

            ),                  Row(

          ),

          const SizedBox(height: 16),                  // Action Buttons                    children: [

          ...schedule.map((item) => Padding(

                padding: const EdgeInsets.only(bottom: 12),                  Row(                      Expanded(

                child: Row(

                  children: [                    children: [                        child: OutlinedButton.icon(

                    Container(

                      width: 48,                      Expanded(                          onPressed: () {

                      height: 48,

                      decoration: BoxDecoration(                        child: OutlinedButton(                            // Make a call

                        color: const Color(0xFFBA78FC).withOpacity(0.1),

                        shape: BoxShape.circle,                          onPressed: phone != null                            final phone = widget.teacher['profile']?['phone'];

                      ),

                      child: const Icon(                              ? () {                            if (phone != null) {

                        Icons.access_time,

                        color: Color(0xFFBA78FC),                                  ScaffoldMessenger.of(context).showSnackBar(                              ScaffoldMessenger.of(context).showSnackBar(

                        size: 24,

                      ),                                    SnackBar(content: Text('Calling $phone...')),                                SnackBar(content: Text('Calling $phone...')),

                    ),

                    const SizedBox(width: 12),                                  );                              );

                    Expanded(

                      child: Column(                                }                            }

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [                              : null,                          },

                          Text(

                            item['time']!,                          style: OutlinedButton.styleFrom(                          icon: const Icon(Icons.phone, size: 18),

                            style: const TextStyle(

                              fontSize: 14,                            foregroundColor: Colors.black87,                          label: const Text(

                              fontWeight: FontWeight.w600,

                            ),                            side: BorderSide(color: Colors.grey[300]!),                            'Call',

                          ),

                          const SizedBox(height: 2),                            shape: RoundedRectangleBorder(                            style: TextStyle(fontWeight: FontWeight.w600),

                          Text(

                            '${item['subject']} - ${item['grade']}',                              borderRadius: BorderRadius.circular(12),                          ),

                            style: TextStyle(

                              fontSize: 13,                            ),                          style: OutlinedButton.styleFrom(

                              color: Colors.grey[600],

                            ),                            padding: const EdgeInsets.symmetric(vertical: 16),                            foregroundColor: Colors.black87,

                          ),

                        ],                          ),                            side: BorderSide(color: Colors.grey[300]!),

                      ),

                    ),                          child: const Text(                            shape: RoundedRectangleBorder(

                    Text(

                      item['room']!,                            'Call',                              borderRadius: BorderRadius.circular(12),

                      style: TextStyle(

                        fontSize: 13,                            style: TextStyle(                            ),

                        color: Colors.grey[600],

                      ),                              fontSize: 16,                            padding: const EdgeInsets.symmetric(vertical: 14),

                    ),

                  ],                              fontWeight: FontWeight.w600,                          ),

                ),

              )),                            ),                        ),

          const SizedBox(height: 8),

          Center(                          ),                      ),

            child: TextButton(

              onPressed: () {},                        ),                      const SizedBox(width: 12),

              child: const Text(

                'View Full Timetable',                      ),                      Expanded(

                style: TextStyle(

                  color: Color(0xFFBA78FC),                      const SizedBox(width: 12),                        flex: 2,

                  fontWeight: FontWeight.w600,

                ),                      Expanded(                        child: ElevatedButton.icon(

              ),

            ),                        flex: 2,                          onPressed: () {

          ),

        ],                        child: ElevatedButton(                            // Send message

      ),

    );                          onPressed: () {                            ScaffoldMessenger.of(context).showSnackBar(

  }

                            ScaffoldMessenger.of(context).showSnackBar(                              const SnackBar(content: Text('Messaging feature coming soon!')),

  Widget _buildAssignedClassesSection() {

    final classes = ['Grade 10A', 'Grade 10B', 'Grade 11A', 'Grade 11B', 'Grade 12C'];                              const SnackBar(                            );



    return Container(                                content: Text('Messaging feature coming soon!'),                          },

      color: Colors.white,

      padding: const EdgeInsets.all(20),                              ),                          icon: const Icon(Icons.message, size: 18),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,                            );                          label: const Text(

        children: [

          const Text(                          },                            'Message',

            'Assigned Classes',

            style: TextStyle(                          style: ElevatedButton.styleFrom(                            style: TextStyle(fontWeight: FontWeight.bold),

              fontSize: 18,

              fontWeight: FontWeight.bold,                            backgroundColor: const Color(0xFFBA78FC),                          ),

            ),

          ),                            foregroundColor: Colors.white,                          style: ElevatedButton.styleFrom(

          const SizedBox(height: 8),

          Text(                            elevation: 0,                            backgroundColor: const Color(AppColors.primary),

            'The teacher is assigned to the following classes.',

            style: TextStyle(                            shape: RoundedRectangleBorder(                            foregroundColor: Colors.white,

              fontSize: 14,

              color: Colors.grey[600],                              borderRadius: BorderRadius.circular(12),                            elevation: 2,

            ),

          ),                            ),                            shadowColor: const Color(AppColors.primary).withOpacity(0.4),

          const SizedBox(height: 16),

          Wrap(                            padding: const EdgeInsets.symmetric(vertical: 16),                            shape: RoundedRectangleBorder(

            spacing: 8,

            runSpacing: 8,                          ),                              borderRadius: BorderRadius.circular(12),

            children: classes.map((className) {

              return Container(                          child: const Text(                            ),

                padding: const EdgeInsets.symmetric(

                  horizontal: 16,                            'Message',                            padding: const EdgeInsets.symmetric(vertical: 14),

                  vertical: 10,

                ),                            style: TextStyle(                          ),

                decoration: BoxDecoration(

                  color: const Color(0xFFBA78FC).withOpacity(0.1),                              fontSize: 16,                        ),

                  borderRadius: BorderRadius.circular(8),

                  border: Border.all(                              fontWeight: FontWeight.bold,                      ),

                    color: const Color(0xFFBA78FC).withOpacity(0.3),

                  ),                            ),                    ],

                ),

                child: Text(                          ),                  ),

                  className,

                  style: const TextStyle(                        ),                ],

                    color: Color(0xFFBA78FC),

                    fontWeight: FontWeight.w600,                      ),              ),

                    fontSize: 13,

                  ),                    ],            ),

                ),

              );                  ),

            }).toList(),

          ),                ],            // Tabs

        ],

      ),              ),            Container(

    );

  }            ),              decoration: BoxDecoration(



  Widget _buildContactSection(String? phone, String? email) {                color: Colors.white,

    return Container(

      color: Colors.white,            const SizedBox(height: 12),                boxShadow: [

      padding: const EdgeInsets.all(20),

      child: Column(                  BoxShadow(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [            // Today's Timetable Section                    color: Colors.black.withOpacity(0.05),

          const Text(

            'Contact Information',            _buildTimetableSection(),                    blurRadius: 2,

            style: TextStyle(

              fontSize: 18,                    offset: const Offset(0, 2),

              fontWeight: FontWeight.bold,

            ),            const SizedBox(height: 12),                  ),

          ),

          const SizedBox(height: 20),                ],

          _buildContactItem(

            Icons.email_outlined,            // Assigned Classes Section              ),

            'Email',

            email ?? 'N/A',            _buildAssignedClassesSection(),              child: TabBar(

          ),

          const SizedBox(height: 16),                isScrollable: true,

          _buildContactItem(

            Icons.phone_outlined,            const SizedBox(height: 12),                labelColor: const Color(AppColors.primary),

            'Phone Number',

            phone ?? 'N/A',                unselectedLabelColor: Colors.grey[600],

          ),

        ],            // Contact Information Section                indicatorColor: const Color(AppColors.primary),

      ),

    );            _buildContactSection(phone, email),                indicatorWeight: 3,

  }

                labelStyle: const TextStyle(

  Widget _buildContactItem(IconData icon, String label, String value) {

    return Row(            const SizedBox(height: 12),                  fontSize: 14,

      children: [

        Container(                  fontWeight: FontWeight.w600,

          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(            // Performance Section                ),

            color: const Color(0xFFBA78FC).withOpacity(0.1),

            borderRadius: BorderRadius.circular(10),            _buildPerformanceSection(),                unselectedLabelStyle: const TextStyle(

          ),

          child: Icon(                  fontSize: 14,

            icon,

            color: const Color(0xFFBA78FC),            const SizedBox(height: 24),                  fontWeight: FontWeight.w500,

            size: 24,

          ),          ],                ),

        ),

        const SizedBox(width: 14),        ),                labelPadding: const EdgeInsets.symmetric(horizontal: 20),

        Expanded(

          child: Column(      ),                indicatorSize: TabBarIndicatorSize.label,

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [    );                tabs: const [

              Text(

                label,  }                  Tab(text: 'Personal'),

                style: TextStyle(

                  fontSize: 13,                  Tab(text: 'Classes'),

                  color: Colors.grey[600],

                ),  Widget _buildTimetableSection() {                  Tab(text: 'Timetable'),

              ),

              const SizedBox(height: 2),    // Mock today's schedule                  Tab(text: 'Attendance'),

              Text(

                value,    final schedule = [                  Tab(text: 'Password'),

                style: const TextStyle(

                  fontSize: 15,      {                ],

                  fontWeight: FontWeight.w500,

                ),        'time': '09:00 - 10:00',              ),

              ),

            ],        'subject': 'Math',            ),

          ),

        ),        'grade': '10A',

      ],

    );        'room': 'Room 201',            // Tab Views

  }

      },            Expanded(

  Widget _buildPerformanceSection() {

    return Container(      {              child: TabBarView(

      color: Colors.white,

      padding: const EdgeInsets.all(20),        'time': '10:00 - 11:00',                children: [

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,        'subject': 'Math',                  _buildPersonalDetailsTab(),

        children: [

          const Text(        'grade': '11B',                  _buildClassesTab(),

            'Performance Metrics',

            style: TextStyle(        'room': 'Room 203',                  _buildTimetableTab(),

              fontSize: 18,

              fontWeight: FontWeight.bold,      },                  _buildAttendanceTab(),

            ),

          ),    ];                  _buildChangePasswordTab(),

          const SizedBox(height: 16),

          Row(                ],

            children: [

              Expanded(    return Container(              ),

                child: _buildMetricCard(

                  'Total Students',      color: Colors.white,            ),

                  '124',

                  Icons.people_outline,      padding: const EdgeInsets.all(20),          ],

                  const Color(0xFFFFB74D),

                ),      child: Column(        ),

              ),

              const SizedBox(width: 12),        crossAxisAlignment: CrossAxisAlignment.start,      ),

              Expanded(

                child: _buildMetricCard(        children: [    );

                  'Avg. Attendance',

                  '92%',          const Text(  }

                  Icons.check_circle_outline,

                  const Color(0xFF66BB6A),            "Today's Timetable",

                ),

              ),            style: TextStyle(  Widget _buildPersonalDetailsTab() {

            ],

          ),              fontSize: 18,    return ListView(

        ],

      ),              fontWeight: FontWeight.bold,      padding: const EdgeInsets.all(16),

    );

  }            ),      children: [



  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {          ),        // Contact Information Section

    return Container(

      padding: const EdgeInsets.all(16),          const SizedBox(height: 16),        Row(

      decoration: BoxDecoration(

        color: color.withOpacity(0.1),          ...schedule.map((item) => Padding(          children: [

        borderRadius: BorderRadius.circular(12),

      ),                padding: const EdgeInsets.only(bottom: 12),            Container(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,                child: Row(              width: 4,

        children: [

          Icon(icon, color: color, size: 28),                  children: [              height: 24,

          const SizedBox(height: 12),

          Text(                    Container(              decoration: BoxDecoration(

            value,

            style: TextStyle(                      width: 48,                color: const Color(AppColors.primary),

              fontSize: 24,

              fontWeight: FontWeight.bold,                      height: 48,                borderRadius: BorderRadius.circular(2),

              color: color,

            ),                      decoration: BoxDecoration(              ),

          ),

          const SizedBox(height: 4),                        color: const Color(0xFFBA78FC).withOpacity(0.1),            ),

          Text(

            label,                        shape: BoxShape.circle,            const SizedBox(width: 12),

            style: TextStyle(

              fontSize: 13,                      ),            const Text(

              color: Colors.grey[600],

            ),                      child: const Icon(              'Contact Information',

          ),

        ],                        Icons.access_time,              style: TextStyle(

      ),

    );                        color: Color(0xFFBA78FC),                fontSize: 18,

  }

                        size: 24,                fontWeight: FontWeight.bold,

  void _showMoreOptions(BuildContext context) {

    showModalBottomSheet(                      ),                color: Colors.black87,

      context: context,

      shape: const RoundedRectangleBorder(                    ),              ),

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),                    const SizedBox(width: 12),            ),

      builder: (context) => Container(

        padding: const EdgeInsets.symmetric(vertical: 20),                    Expanded(          ],

        child: Column(

          mainAxisSize: MainAxisSize.min,                      child: Column(        ),

          children: [

            ListTile(                        crossAxisAlignment: CrossAxisAlignment.start,        const SizedBox(height: 16),

              leading: const Icon(Icons.edit, color: Color(0xFFBA78FC)),

              title: const Text('Edit Profile'),                        children: [

              onTap: () {

                Navigator.pop(context);                          Text(        _buildInfoItem(

                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(content: Text('Edit feature coming soon!')),                            item['time']!,          Icons.phone,

                );

              },                            style: const TextStyle(          'Phone',

            ),

            ListTile(                              fontSize: 14,          widget.teacher['profile']?['phone'] ?? '+91 98765 43210',

              leading: const Icon(Icons.schedule, color: Color(0xFFBA78FC)),

              title: const Text('View Full Schedule'),                              fontWeight: FontWeight.w600,        ),

              onTap: () {

                Navigator.pop(context);                            ),        _buildInfoItem(

              },

            ),                          ),          Icons.email_outlined,

            ListTile(

              leading: const Icon(Icons.assessment, color: Color(0xFFBA78FC)),                          const SizedBox(height: 2),          'Email',

              title: const Text('View Reports'),

              onTap: () {                          Text(          widget.teacher['email'] ?? 'teacher@schoolname.edu',

                Navigator.pop(context);

              },                            '${item['subject']} - ${item['grade']}',        ),

            ),

            const Divider(),                            style: TextStyle(        _buildInfoItem(

            ListTile(

              leading: const Icon(Icons.person_off, color: Colors.red),                              fontSize: 13,          Icons.home_outlined,

              title: const Text('Deactivate Account'),

              textColor: Colors.red,                              color: Colors.grey[600],          'Address',

              onTap: () {

                Navigator.pop(context);                            ),          widget.teacher['profile']?['address'] ?? '#123, Maple Street, Bengaluru, KA 560001',

                _showDeactivateDialog(context);

              },                          ),        ),

            ),

          ],                        ],

        ),

      ),                      ),        const SizedBox(height: 24),

    );

  }                    ),



  void _showDeactivateDialog(BuildContext context) {                    Text(        // Personal Information Section

    showDialog(

      context: context,                      item['room']!,        Row(

      builder: (context) => AlertDialog(

        title: const Text('Deactivate Account'),                      style: TextStyle(          children: [

        content: const Text(

          'Are you sure you want to deactivate this teacher account? This action can be reversed later.',                        fontSize: 13,            Container(

        ),

        actions: [                        color: Colors.grey[600],              width: 4,

          TextButton(

            onPressed: () => Navigator.pop(context),                      ),              height: 24,

            child: const Text('Cancel'),

          ),                    ),              decoration: BoxDecoration(

          TextButton(

            onPressed: () {                  ],                color: const Color(AppColors.primary),

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(                ),                borderRadius: BorderRadius.circular(2),

                const SnackBar(

                  content: Text('Account deactivation feature coming soon!'),              )),              ),

                ),

              );          const SizedBox(height: 8),            ),

            },

            style: TextButton.styleFrom(foregroundColor: Colors.red),          Center(            const SizedBox(width: 12),

            child: const Text('Deactivate'),

          ),            child: TextButton(            const Text(

        ],

      ),              onPressed: () {},              'Personal Information',

    );

  }              child: const Text(              style: TextStyle(

}

                'View Full Timetable',                fontSize: 18,

                style: TextStyle(                fontWeight: FontWeight.bold,

                  color: Color(0xFFBA78FC),                color: Colors.black87,

                  fontWeight: FontWeight.w600,              ),

                ),            ),

              ),          ],

            ),        ),

          ),        const SizedBox(height: 16),

        ],

      ),        _buildInfoItem(

    );          Icons.cake_outlined,

  }          'Date of Birth',

          widget.teacher['profile']?['dateOfBirth'] ?? '15th August, 1985',

  Widget _buildAssignedClassesSection() {        ),

    final classes = ['Grade 10A', 'Grade 10B', 'Grade 11A', 'Grade 11B', 'Grade 12C'];        _buildInfoItem(

          Icons.calendar_today_outlined,

    return Container(          'Date of Joining',

      color: Colors.white,          widget.teacher['profile']?['joiningDate'] ?? '1st June, 2010',

      padding: const EdgeInsets.all(20),        ),

      child: Column(        _buildInfoItem(

        crossAxisAlignment: CrossAxisAlignment.start,          Icons.contact_emergency_outlined,

        children: [          'Emergency Contact',

          const Text(          widget.teacher['profile']?['emergencyContact'] ?? 'Anil Sharma (Spouse) - +91 98765 11223',

            'Assigned Classes',        ),

            style: TextStyle(      ],

              fontSize: 18,    );

              fontWeight: FontWeight.bold,  }

            ),

          ),  Widget _buildInfoItem(IconData icon, String label, String value) {

          const SizedBox(height: 8),    return Container(

          Text(      margin: const EdgeInsets.only(bottom: 16),

            'The teacher is assigned to the following classes.',      padding: const EdgeInsets.all(16),

            style: TextStyle(      decoration: BoxDecoration(

              fontSize: 14,        color: Colors.white,

              color: Colors.grey[600],        borderRadius: BorderRadius.circular(12),

            ),        boxShadow: [

          ),          BoxShadow(

          const SizedBox(height: 16),            color: Colors.black.withOpacity(0.05),

          Wrap(            blurRadius: 4,

            spacing: 8,            offset: const Offset(0, 2),

            runSpacing: 8,          ),

            children: classes.map((className) {        ],

              return Container(      ),

                padding: const EdgeInsets.symmetric(      child: Row(

                  horizontal: 16,        children: [

                  vertical: 10,          Container(

                ),            padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(            decoration: BoxDecoration(

                  color: const Color(0xFFBA78FC).withOpacity(0.1),              color: const Color(AppColors.primary).withOpacity(0.1),

                  borderRadius: BorderRadius.circular(8),              borderRadius: BorderRadius.circular(10),

                  border: Border.all(            ),

                    color: const Color(0xFFBA78FC).withOpacity(0.3),            child: Icon(

                  ),              icon,

                ),              color: const Color(AppColors.primary),

                child: Text(              size: 24,

                  className,            ),

                  style: const TextStyle(          ),

                    color: Color(0xFFBA78FC),          const SizedBox(width: 16),

                    fontWeight: FontWeight.w600,          Expanded(

                    fontSize: 13,            child: Column(

                  ),              crossAxisAlignment: CrossAxisAlignment.start,

                ),              children: [

              );                Text(

            }).toList(),                  label,

          ),                  style: TextStyle(

        ],                    fontSize: 12,

      ),                    color: Colors.grey[600],

    );                    fontWeight: FontWeight.w500,

  }                  ),

                ),

  Widget _buildContactSection(String? phone, String? email) {                const SizedBox(height: 4),

    return Container(                Text(

      color: Colors.white,                  value,

      padding: const EdgeInsets.all(20),                  style: const TextStyle(

      child: Column(                    fontSize: 14,

        crossAxisAlignment: CrossAxisAlignment.start,                    color: Colors.black87,

        children: [                    fontWeight: FontWeight.w600,

          const Text(                  ),

            'Contact Information',                ),

            style: TextStyle(              ],

              fontSize: 18,            ),

              fontWeight: FontWeight.bold,          ),

            ),        ],

          ),      ),

          const SizedBox(height: 20),    );

          _buildContactItem(  }

            Icons.email_outlined,

            'Email',  Widget _buildClassesTab() {

            email ?? 'N/A',    // Mock classes data

          ),    final List<Map<String, dynamic>> classes = [

          const SizedBox(height: 16),      {'name': 'Class 10 - Section A', 'subject': 'Mathematics', 'students': 35},

          _buildContactItem(      {'name': 'Class 9 - Section B', 'subject': 'Mathematics', 'students': 32},

            Icons.phone_outlined,      {'name': 'Class 8 - Section A', 'subject': 'Mathematics', 'students': 30},

            'Phone Number',    ];

            phone ?? 'N/A',

          ),    return ListView(

        ],      padding: const EdgeInsets.all(16),

      ),      children: [

    );        Row(

  }          children: [

            Container(

  Widget _buildContactItem(IconData icon, String label, String value) {              width: 4,

    return Row(              height: 24,

      children: [              decoration: BoxDecoration(

        Container(                color: const Color(AppColors.primary),

          padding: const EdgeInsets.all(10),                borderRadius: BorderRadius.circular(2),

          decoration: BoxDecoration(              ),

            color: const Color(0xFFBA78FC).withOpacity(0.1),            ),

            borderRadius: BorderRadius.circular(10),            const SizedBox(width: 12),

          ),            const Text(

          child: Icon(              'Assigned Classes',

            icon,              style: TextStyle(

            color: const Color(0xFFBA78FC),                fontSize: 18,

            size: 24,                fontWeight: FontWeight.bold,

          ),                color: Colors.black87,

        ),              ),

        const SizedBox(width: 14),            ),

        Expanded(          ],

          child: Column(        ),

            crossAxisAlignment: CrossAxisAlignment.start,        const SizedBox(height: 16),

            children: [

              Text(        ...classes.map((classInfo) => _buildClassCard(classInfo)),

                label,      ],

                style: TextStyle(    );

                  fontSize: 13,  }

                  color: Colors.grey[600],

                ),  Widget _buildClassCard(Map<String, dynamic> classInfo) {

              ),    return Container(

              const SizedBox(height: 2),      margin: const EdgeInsets.only(bottom: 12),

              Text(      padding: const EdgeInsets.all(16),

                value,      decoration: BoxDecoration(

                style: const TextStyle(        color: Colors.white,

                  fontSize: 15,        borderRadius: BorderRadius.circular(12),

                  fontWeight: FontWeight.w500,        border: Border.all(color: Colors.grey[200]!),

                ),        boxShadow: [

              ),          BoxShadow(

            ],            color: Colors.black.withOpacity(0.05),

          ),            blurRadius: 4,

        ),            offset: const Offset(0, 2),

      ],          ),

    );        ],

  }      ),

      child: Row(

  Widget _buildPerformanceSection() {        children: [

    return Container(          Container(

      color: Colors.white,            padding: const EdgeInsets.all(12),

      padding: const EdgeInsets.all(20),            decoration: BoxDecoration(

      child: Column(              color: const Color(AppColors.primary).withOpacity(0.1),

        crossAxisAlignment: CrossAxisAlignment.start,              borderRadius: BorderRadius.circular(10),

        children: [            ),

          const Text(            child: const Icon(

            'Performance Metrics',              Icons.class_outlined,

            style: TextStyle(              color: Color(AppColors.primary),

              fontSize: 18,              size: 28,

              fontWeight: FontWeight.bold,            ),

            ),          ),

          ),          const SizedBox(width: 16),

          const SizedBox(height: 16),          Expanded(

          Row(            child: Column(

            children: [              crossAxisAlignment: CrossAxisAlignment.start,

              Expanded(              children: [

                child: _buildMetricCard(                Text(

                  'Total Students',                  classInfo['name'],

                  '124',                  style: const TextStyle(

                  Icons.people_outline,                    fontSize: 15,

                  const Color(0xFFFFB74D),                    fontWeight: FontWeight.bold,

                ),                    color: Colors.black87,

              ),                  ),

              const SizedBox(width: 12),                ),

              Expanded(                const SizedBox(height: 4),

                child: _buildMetricCard(                Text(

                  'Avg. Attendance',                  classInfo['subject'],

                  '92%',                  style: TextStyle(

                  Icons.check_circle_outline,                    fontSize: 13,

                  const Color(0xFF66BB6A),                    color: Colors.grey[600],

                ),                  ),

              ),                ),

            ],              ],

          ),            ),

        ],          ),

      ),          Column(

    );            crossAxisAlignment: CrossAxisAlignment.end,

  }            children: [

              Text(

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {                '${classInfo['students']}',

    return Container(                style: const TextStyle(

      padding: const EdgeInsets.all(16),                  fontSize: 18,

      decoration: BoxDecoration(                  fontWeight: FontWeight.bold,

        color: color.withOpacity(0.1),                  color: Color(AppColors.primary),

        borderRadius: BorderRadius.circular(12),                ),

      ),              ),

      child: Column(              Text(

        crossAxisAlignment: CrossAxisAlignment.start,                'Students',

        children: [                style: TextStyle(

          Icon(icon, color: color, size: 28),                  fontSize: 11,

          const SizedBox(height: 12),                  color: Colors.grey[500],

          Text(                ),

            value,              ),

            style: TextStyle(            ],

              fontSize: 24,          ),

              fontWeight: FontWeight.bold,        ],

              color: color,      ),

            ),    );

          ),  }

          const SizedBox(height: 4),

          Text(  Widget _buildTimetableTab() {

            label,    // Mock timetable data

            style: TextStyle(    final List<Map<String, dynamic>> schedule = [

              fontSize: 13,      {

              color: Colors.grey[600],        'day': 'Monday',

            ),        'periods': [

          ),          {'time': '9:00 - 10:00', 'class': 'Class 10-A', 'subject': 'Maths'},

        ],          {'time': '11:00 - 12:00', 'class': 'Class 9-B', 'subject': 'Maths'},

      ),        ],

    );      },

  }      {

        'day': 'Tuesday',

  void _showMoreOptions(BuildContext context) {        'periods': [

    showModalBottomSheet(          {'time': '10:00 - 11:00', 'class': 'Class 8-A', 'subject': 'Maths'},

      context: context,          {'time': '2:00 - 3:00', 'class': 'Class 10-A', 'subject': 'Maths'},

      shape: const RoundedRectangleBorder(        ],

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),      },

      ),      {

      builder: (context) => Container(        'day': 'Wednesday',

        padding: const EdgeInsets.symmetric(vertical: 20),        'periods': [

        child: Column(          {'time': '9:00 - 10:00', 'class': 'Class 9-B', 'subject': 'Maths'},

          mainAxisSize: MainAxisSize.min,          {'time': '11:00 - 12:00', 'class': 'Class 10-A', 'subject': 'Maths'},

          children: [        ],

            ListTile(      },

              leading: const Icon(Icons.edit, color: Color(0xFFBA78FC)),    ];

              title: const Text('Edit Profile'),

              onTap: () {    return ListView(

                Navigator.pop(context);      padding: const EdgeInsets.all(16),

                ScaffoldMessenger.of(context).showSnackBar(      children: [

                  const SnackBar(content: Text('Edit feature coming soon!')),        Row(

                );          children: [

              },            Container(

            ),              width: 4,

            ListTile(              height: 24,

              leading: const Icon(Icons.schedule, color: Color(0xFFBA78FC)),              decoration: BoxDecoration(

              title: const Text('View Full Schedule'),                color: const Color(AppColors.primary),

              onTap: () {                borderRadius: BorderRadius.circular(2),

                Navigator.pop(context);              ),

              },            ),

            ),            const SizedBox(width: 12),

            ListTile(            const Text(

              leading: const Icon(Icons.assessment, color: Color(0xFFBA78FC)),              'Weekly Schedule',

              title: const Text('View Reports'),              style: TextStyle(

              onTap: () {                fontSize: 18,

                Navigator.pop(context);                fontWeight: FontWeight.bold,

              },                color: Colors.black87,

            ),              ),

            const Divider(),            ),

            ListTile(          ],

              leading: const Icon(Icons.person_off, color: Colors.red),        ),

              title: const Text('Deactivate Account'),        const SizedBox(height: 16),

              textColor: Colors.red,

              onTap: () {        ...schedule.map((day) => _buildDaySchedule(day)),

                Navigator.pop(context);      ],

                _showDeactivateDialog(context);    );

              },  }

            ),

          ],  Widget _buildDaySchedule(Map<String, dynamic> day) {

        ),    return Container(

      ),      margin: const EdgeInsets.only(bottom: 16),

    );      decoration: BoxDecoration(

  }        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

  void _showDeactivateDialog(BuildContext context) {        border: Border.all(color: Colors.grey[200]!),

    showDialog(        boxShadow: [

      context: context,          BoxShadow(

      builder: (context) => AlertDialog(            color: Colors.black.withOpacity(0.05),

        title: const Text('Deactivate Account'),            blurRadius: 4,

        content: const Text(            offset: const Offset(0, 2),

          'Are you sure you want to deactivate this teacher account? This action can be reversed later.',          ),

        ),        ],

        actions: [      ),

          TextButton(      child: Column(

            onPressed: () => Navigator.pop(context),        crossAxisAlignment: CrossAxisAlignment.start,

            child: const Text('Cancel'),        children: [

          ),          Container(

          TextButton(            padding: const EdgeInsets.all(12),

            onPressed: () {            decoration: BoxDecoration(

              Navigator.pop(context);              color: const Color(AppColors.primary).withOpacity(0.1),

              ScaffoldMessenger.of(context).showSnackBar(              borderRadius: const BorderRadius.only(

                const SnackBar(                topLeft: Radius.circular(12),

                  content: Text('Account deactivation feature coming soon!'),                topRight: Radius.circular(12),

                ),              ),

              );            ),

            },            child: Row(

            style: TextButton.styleFrom(foregroundColor: Colors.red),              children: [

            child: const Text('Deactivate'),                const Icon(

          ),                  Icons.calendar_today,

        ],                  size: 18,

      ),                  color: Color(AppColors.primary),

    );                ),

  }                const SizedBox(width: 8),

}                Text(

                  day['day'],
                  style: const TextStyle(
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
              colors: [const Color(AppColors.primary), const Color(AppColors.primary).withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(AppColors.primary).withOpacity(0.3),
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
                color: const Color(AppColors.primary),
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
        ...attendanceRecords.map((record) => _buildAttendanceCard(record)),
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
                  color: const Color(AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      record['hours'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.primary),
                      ),
                    ),
                    const Text(
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
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

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
                      controller: newPasswordController,
                      obscureText: obscureNewPassword,
                      decoration: InputDecoration(
                        hintText: 'Enter new password',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.lock, color: Color(AppColors.primary)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              obscureNewPassword = !obscureNewPassword;
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
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Re-enter new password',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(AppColors.primary)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
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
                      const Color(AppColors.primary),
                      const Color(AppColors.primary).withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(AppColors.primary).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Validate passwords
                    if (newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password must be at least 6 characters'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (newPasswordController.text != confirmPasswordController.text) {
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
                    newPasswordController.clear();
                    confirmPasswordController.clear();
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
