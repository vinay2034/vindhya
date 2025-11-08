import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class StudentAttendanceDetailScreen extends StatefulWidget {
  final String? classId;
  final String? className;
  final DateTime startDate;
  final DateTime endDate;

  const StudentAttendanceDetailScreen({
    super.key,
    this.classId,
    this.className,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<StudentAttendanceDetailScreen> createState() =>
      _StudentAttendanceDetailScreenState();
}

class _StudentAttendanceDetailScreenState
    extends State<StudentAttendanceDetailScreen> {
  late ApiService _apiService;
  List<dynamic> _students = [];
  bool _isLoading = true;
  String _sortBy = 'name'; // name, present, absent, late

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storageService = StorageService();
    await storageService.init();
    _apiService = ApiService(storageService);
    await _loadAttendanceDetails();
  }

  Future<void> _loadAttendanceDetails() async {
    setState(() => _isLoading = true);

    try {
      final queryParams = {
        'startDate': widget.startDate.toIso8601String(),
        'endDate': widget.endDate.toIso8601String(),
      };

      if (widget.classId != null) {
        queryParams['classId'] = widget.classId!;
      }

      final response = await _apiService.get(
        '/admin/reports/attendance',
        queryParameters: queryParams,
      );

      final List<dynamic> attendanceData =
          response.data['data']['attendanceData'] ?? [];

      // Group attendance by student
      Map<String, List<Map<String, dynamic>>> groupedData = {};
      Map<String, dynamic> studentInfo = {};

      for (var record in attendanceData) {
        final studentData = record['studentId'] as Map<String, dynamic>;
        final studentId = studentData['_id'] as String;
        
        // Handle name field - API returns 'name' not firstName/lastName
        final studentName = studentData['name'] as String? ?? 
            '${studentData['firstName'] ?? ''} ${studentData['lastName'] ?? ''}'.trim();
        
        if (!groupedData.containsKey(studentId)) {
          groupedData[studentId] = [];
          studentInfo[studentId] = {
            'id': studentId,
            'name': studentName,
            'rollNumber': studentData['rollNumber']?.toString() ?? '',
            'photo': studentData['photo'],
          };
        }

        groupedData[studentId]!.add({
          'date': DateTime.parse(record['date'] as String),
          'status': record['status'] as String,
        });
      }

      // Convert to list format with stats
      List<dynamic> studentsList = [];
      groupedData.forEach((studentId, attendance) {
        final student = studentInfo[studentId]!;
        final presentCount =
            attendance.where((a) => a['status'] == 'present').length;
        final absentCount =
            attendance.where((a) => a['status'] == 'absent').length;
        final lateCount = attendance.where((a) => a['status'] == 'late').length;

        studentsList.add(<String, dynamic>{
          'id': student['id'],
          'name': student['name'],
          'rollNumber': student['rollNumber'],
          'photo': student['photo'],
          'attendance': attendance,
          'present': presentCount,
          'absent': absentCount,
          'late': lateCount,
          'total': attendance.length,
        });
      });

      setState(() {
        _students = studentsList;
        _isLoading = false;
      });

      _sortStudents();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading attendance: $e')),
        );
      }
    }
  }

  void _sortStudents() {
    setState(() {
      _students.sort((a, b) {
        switch (_sortBy) {
          case 'present':
            return (b['present'] as int).compareTo(a['present'] as int);
          case 'absent':
            return (b['absent'] as int).compareTo(a['absent'] as int);
          case 'late':
            return (b['late'] as int).compareTo(a['late'] as int);
          case 'name':
          default:
            return (a['name'] as String).compareTo(b['name'] as String);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.className ?? 'Student List',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() => _sortBy = value);
              _sortStudents();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem(
                value: 'present',
                child: Text('Sort by Present'),
              ),
              const PopupMenuItem(
                value: 'absent',
                child: Text('Sort by Absent'),
              ),
              const PopupMenuItem(
                value: 'late',
                child: Text('Sort by Late'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No attendance records found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[50],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Sort',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.swap_vert,
                              size: 20, color: const Color(0xFFBA78FC)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          return _buildStudentCard(student);
                        },
                      ),
                    ),
                    _buildGenerateReportButton(),
                  ],
                ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final attendanceList = student['attendance'];
    final List<Map<String, dynamic>> attendance = 
        (attendanceList as List).map((e) => e as Map<String, dynamic>).toList();
    final int presentCount = student['present'] as int;
    final int absentCount = student['absent'] as int;
    final int lateCount = student['late'] as int;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: student['photo'] != null
                ? NetworkImage(student['photo'])
                : null,
            child: student['photo'] == null
                ? Text(
                    student['name'].toString().substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            student['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                _buildStatusBadge('P', presentCount, const Color(0xFF28A745)),
                const SizedBox(width: 6),
                _buildStatusBadge('L', lateCount, const Color(0xFFFFC107)),
                const SizedBox(width: 6),
                _buildStatusBadge('A', absentCount, const Color(0xFFDC3545)),
                const SizedBox(width: 6),
                _buildStatusBadge('H', 0, const Color(0xFF6C757D)), // Holiday
                const SizedBox(width: 6),
                _buildStatusBadge('E', 0, const Color(0xFF17A2B8)), // Excused
              ],
            ),
          ),
          children: [
            _buildAttendanceHistory(attendance),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, int count, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceHistory(List<Map<String, dynamic>> attendance) {
    // Sort by date descending
    final sortedAttendance = List<Map<String, dynamic>>.from(attendance)
      ..sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed History (This Week)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...sortedAttendance.take(7).map((record) {
            final date = record['date'] as DateTime;
            final status = record['status'] as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatFullDate(date),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusLabel(status),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return const Color(0xFF28A745);
      case 'absent':
        return const Color(0xFFDC3545);
      case 'late':
        return const Color(0xFFFFC107);
      case 'holiday':
        return const Color(0xFF6C757D);
      case 'excused':
        return const Color(0xFF17A2B8);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'absent':
        return 'Absent';
      case 'late':
        return 'Late';
      case 'holiday':
        return 'Holiday';
      case 'excused':
        return 'Excused';
      default:
        return status;
    }
  }

  String _formatFullDate(DateTime date) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final weekDay = weekDays[(date.weekday - 1) % 7];
    final month = months[date.month - 1];
    
    return '$weekDay, $month ${date.day}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildGenerateReportButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _generateReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBA78FC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.description),
          label: const Text(
            'Generate Report',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _generateReport() async {
    try {
      final pdf = pw.Document();

      // Calculate totals
      int totalPresent = 0;
      int totalAbsent = 0;
      int totalLate = 0;
      int totalRecords = 0;

      for (var student in _students) {
        totalPresent += student['present'] as int;
        totalAbsent += student['absent'] as int;
        totalLate += student['late'] as int;
        totalRecords += student['total'] as int;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Attendance Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    widget.className ?? 'All Classes',
                    style: const pw.TextStyle(fontSize: 18),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Period: ${_formatDate(widget.startDate)} - ${_formatDate(widget.endDate)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),

            // Summary Statistics
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfStat('Total Students', '${_students.length}'),
                  _buildPdfStat('Present', '$totalPresent'),
                  _buildPdfStat('Absent', '$totalAbsent'),
                  _buildPdfStat('Late', '$totalLate'),
                  _buildPdfStat(
                    'Attendance Rate',
                    '${totalRecords > 0 ? ((totalPresent / totalRecords) * 100).toStringAsFixed(1) : 0}%',
                  ),
                ],
              ),
            ),

            // Student List Table
            pw.SizedBox(height: 24),
            pw.Text(
              'Student Attendance Details',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),

            // Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FixedColumnWidth(40),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FixedColumnWidth(60),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(60),
                5: const pw.FixedColumnWidth(60),
                6: const pw.FixedColumnWidth(80),
              },
              children: [
                // Header Row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    _buildTableHeader('#'),
                    _buildTableHeader('Student Name'),
                    _buildTableHeader('Roll No'),
                    _buildTableHeader('Present'),
                    _buildTableHeader('Absent'),
                    _buildTableHeader('Late'),
                    _buildTableHeader('Total'),
                  ],
                ),
                // Data Rows
                ..._students.asMap().entries.map((entry) {
                  final index = entry.key;
                  final student = entry.value;
                  return pw.TableRow(
                    children: [
                      _buildTableCell('${index + 1}'),
                      _buildTableCell(student['name'] as String),
                      _buildTableCell(student['rollNumber'] as String),
                      _buildTableCell('${student['present']}',
                          color: PdfColors.green),
                      _buildTableCell('${student['absent']}',
                          color: PdfColors.red),
                      _buildTableCell('${student['late']}',
                          color: PdfColors.orange),
                      _buildTableCell('${student['total']}'),
                    ],
                  );
                }).toList(),
              ],
            ),

            // Footer Note
            pw.SizedBox(height: 24),
            pw.Text(
              'Generated on: ${DateTime.now().toString().split('.')[0]}',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
      );

      // Show print preview or download
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'attendance_report_${widget.className?.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report generated successfully!'),
            backgroundColor: Color(0xFF28A745),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: const Color(0xFFDC3545),
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: color,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
