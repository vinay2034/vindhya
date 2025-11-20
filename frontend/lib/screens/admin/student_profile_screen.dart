import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class StudentProfileScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentProfileScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late ApiService _apiService;
  List<dynamic> _attendanceRecords = [];
  bool _isLoadingAttendance = false;
  int _presentCount = 0;
  int _absentCount = 0;
  int _lateCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storageService = StorageService();
    await storageService.init();
    _apiService = ApiService(storageService);
    await _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoadingAttendance = true);

    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final response = await _apiService.get(
        '/admin/reports/attendance',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      final List<dynamic> allAttendance = response.data['data']['attendanceData'] ?? [];
      
      final studentAttendance = allAttendance.where((record) {
        return record['studentId']['_id'] == widget.student['_id'];
      }).toList();

      int present = 0, absent = 0, late = 0;
      for (var record in studentAttendance) {
        final status = record['status'] as String;
        if (status == 'present') {
          present++;
        } else if (status == 'absent') absent++;
        else if (status == 'late') late++;
      }

      setState(() {
        _attendanceRecords = studentAttendance;
        _presentCount = present;
        _absentCount = absent;
        _lateCount = late;
        _isLoadingAttendance = false;
      });
    } catch (e) {
      setState(() => _isLoadingAttendance = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading attendance: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header - Horizontal Layout
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(AppColors.primary),
                    child: Text(
                      _getInitials(widget.student['name'] ?? 'Student'),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  
                  // Student Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.student['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Grade ${_getGradeNumber(widget.student['classId']?['className'])} - Class ${widget.student['classId']?['section'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Tabs
            DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  TabBar(
                    labelColor: const Color(AppColors.primary),
                    unselectedLabelColor: Colors.grey[600],
                    indicatorColor: const Color(AppColors.primary),
                    tabs: const [
                      Tab(text: 'Details'),
                      Tab(text: 'Attendance'),
                      Tab(text: 'Grades'),
                      Tab(text: 'Fees'),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      children: [
                        _buildDetailsTab(),
                        _buildAttendanceTab(),
                        _buildGradesTab(),
                        _buildFeesTab(),
                      ],
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

  String _getGradeNumber(String? className) {
    if (className == null) return 'N/A';
    final match = RegExp(r'(\d+)').firstMatch(className);
    if (match != null) {
      return match.group(1)!;
    }
    return className;
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Date of Birth', _formatDate(widget.student['dateOfBirth'])),
          _buildInfoRow('Gender', (widget.student['gender']?.toString() ?? 'N/A').capitalize()),
          _buildInfoRow('Blood Group', widget.student['bloodGroup'] ?? 'N/A'),
          _buildInfoRow('Admission No', widget.student['admissionNumber'] ?? 'N/A'),
          _buildInfoRow('Admission Date', _formatDate(widget.student['admissionDate'])),
          _buildInfoRow('Address', widget.student['address'] ?? 'N/A'),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Parent/Guardian Contact'),
          const SizedBox(height: 12),
          _buildContactRow(
            'Name',
            widget.student['emergencyContact']?['fatherName'] ?? 'N/A',
            hasActions: true,
          ),
          _buildInfoRow('Email', widget.student['parentId']?['email'] ?? 'N/A'),
          _buildInfoRow('Phone', widget.student['emergencyContact']?['phone'] ?? 'N/A'),
          
          const SizedBox(height: 24),
          
          _buildSectionTitle('Emergency Contact'),
          const SizedBox(height: 12),
          _buildContactRow(
            'Name',
            '${widget.student['emergencyContact']?['motherName'] ?? 'N/A'} (${(widget.student['emergencyContact']?['relation']?.toString() ?? 'N/A').capitalize()})',
            hasActions: false,
          ),
          _buildInfoRow('Phone', widget.student['emergencyContact']?['phone'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    if (_isLoadingAttendance) {
      return const Center(child: CircularProgressIndicator());
    }

    final total = _presentCount + _absentCount + _lateCount;
    final attendancePercentage = total > 0 
        ? ((_presentCount + _lateCount) / total * 100).toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Attendance Summary (Last 30 Days)'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Present',
                    _presentCount.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Absent',
                    _absentCount.toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Late',
                    _lateCount.toString(),
                    Colors.orange,
                    Icons.access_time,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(AppColors.primary), const Color(AppColors.primary).withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(AppColors.primary).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Overall Attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$attendancePercentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on $total days',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSectionTitle('Recent Records'),
            const SizedBox(height: 12),
            
            _attendanceRecords.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No attendance records found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _attendanceRecords.length > 10 ? 10 : _attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = _attendanceRecords[index];
                      final date = DateTime.parse(record['date']);
                      final status = record['status'] as String;
                      
                      IconData iconData;
                      Color statusColor;
                      String statusText;
                      
                      switch (status) {
                        case 'present':
                          iconData = Icons.check_circle;
                          statusColor = Colors.green;
                          statusText = 'Present';
                          break;
                        case 'absent':
                          iconData = Icons.cancel;
                          statusColor = Colors.red;
                          statusText = 'Absent';
                          break;
                        case 'late':
                          iconData = Icons.access_time;
                          statusColor = Colors.orange;
                          statusText = 'Late';
                          break;
                        default:
                          iconData = Icons.help_outline;
                          statusColor = Colors.grey;
                          statusText = status.capitalize();
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              iconData,
                              color: statusColor,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(date.toString()),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: statusColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Grade records will be displayed here',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value, {required bool hasActions}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (hasActions) ...[
            const SizedBox(width: 8),
            const Icon(Icons.message_outlined, size: 18, color: Color(AppColors.primary)),
            const SizedBox(width: 8),
            const Icon(Icons.call_outlined, size: 18, color: Color(AppColors.secondary)),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    List<String> names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'S';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      DateTime dateTime = date is String ? DateTime.parse(date) : date;
      return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildFeesTab() {
    // Mock fee data - in real app, this would come from API
    final List<Map<String, dynamic>> feeInvoices = [
      {
        'title': 'Term 2 Tuition Fee',
        'amount': 750.00,
        'dueDate': '15 Oct 2023',
        'status': 'Overdue',
        'color': Colors.red,
        'icon': Icons.error_outline,
      },
      {
        'title': 'Extracurricular Activities',
        'amount': 500.00,
        'dueDate': '30 Nov 2023',
        'status': 'Pending',
        'color': Colors.orange,
        'icon': Icons.hourglass_empty,
      },
      {
        'title': 'Term 1 Tuition Fee',
        'amount': 5500.00,
        'paidDate': '12 Aug 2023',
        'status': 'Paid',
        'color': Colors.green,
        'icon': Icons.check_circle_outline,
      },
    ];

    final double outstandingBalance = feeInvoices
        .where((fee) => fee['status'] != 'Paid')
        .fold(0.0, (sum, fee) => sum + fee['amount']);

    final double totalPaid = feeInvoices
        .where((fee) => fee['status'] == 'Paid')
        .fold(0.0, (sum, fee) => sum + fee['amount']);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildFeeSummaryCard(
                'Outstanding\nBalance',
                '₹${outstandingBalance.toStringAsFixed(2)}',
                Colors.red.shade50,
                Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeSummaryCard(
                'Total Paid',
                '₹${totalPaid.toStringAsFixed(2)}',
                Colors.green.shade50,
                Colors.green.shade700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Tabs for Invoices and Payment History
        DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  indicator: BoxDecoration(
                    color: const Color(AppColors.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tabs: const [
                    Tab(text: 'Invoices'),
                    Tab(text: 'Payment History'),
                  ],
                ),
              ),
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    // Invoices Tab
                    ListView.builder(
                      padding: const EdgeInsets.only(top: 16),
                      itemCount: feeInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = feeInvoices[index];
                        return _buildFeeInvoiceCard(invoice);
                      },
                    ),
                    // Payment History Tab
                    ListView.builder(
                      padding: const EdgeInsets.only(top: 16),
                      itemCount: feeInvoices.where((f) => f['status'] == 'Paid').length,
                      itemBuilder: (context, index) {
                        final paidInvoices = feeInvoices.where((f) => f['status'] == 'Paid').toList();
                        return _buildFeeInvoiceCard(paidInvoices[index]);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Pay Now Button
        if (outstandingBalance > 0)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment gateway integration coming soon!'),
                    backgroundColor: Color(AppColors.primary),
                  ),
                );
              },
              icon: const Icon(Icons.payment),
              label: Text('Pay Now (₹${outstandingBalance.toStringAsFixed(2)})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primary),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeeSummaryCard(String label, String amount, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeInvoiceCard(Map<String, dynamic> invoice) {
    final bool isPaid = invoice['status'] == 'Paid';
    final Color statusColor = invoice['color'];
    final String dateLabel = isPaid ? 'Paid on: ${invoice['paidDate']}' : 'Due Date: ${invoice['dueDate']}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                invoice['icon'],
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      invoice['status'].toString().toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    invoice['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Date
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '₹${invoice['amount'].toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
