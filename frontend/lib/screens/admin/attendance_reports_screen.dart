import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'student_attendance_detail_screen.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({super.key});

  @override
  State<AttendanceReportsScreen> createState() => _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen> {
  late ApiService _apiService;
  final TextEditingController _searchController = TextEditingController();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String? _selectedClassId;
  
  List<dynamic> _classes = [];
  Map<String, Map<String, int>> _dailySummary = {};
  bool _isLoading = true;
  
  int _presentCount = 0;
  int _absentCount = 0;
  int _lateCount = 0;
  int _totalStudents = 0;

  double get _presentPercentage => _totalStudents > 0 ? (_presentCount / _totalStudents * 100) : 0;
  double get _absentPercentage => _totalStudents > 0 ? (_absentCount / _totalStudents * 100) : 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storageService = StorageService();
    await storageService.init();
    _apiService = ApiService(storageService);
    await _loadClasses();
    await _loadAttendanceData();
  }

  Future<void> _loadClasses() async {
    try {
      final response = await _apiService.getClasses();
      setState(() {
        _classes = (response['data']?['classes'] as List<dynamic>?) ?? [];
      });
    } catch (e) {
      print('Error loading classes: $e');
    }
  }

  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = {
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
      };
      
      if (_selectedClassId != null) {
        queryParams['classId'] = _selectedClassId!;
      }

      final response = await _apiService.get(
        '/admin/reports/attendance',
        queryParameters: queryParams,
      );

      print('Attendance API Response: ${response.data}');
      
      final data = (response.data['data']?['attendanceData'] as List<dynamic>?) ?? [];
      
      print('Attendance data count: ${data.length}');
      
      _calculateStats(data);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading attendance data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _calculateStats(List<dynamic> data) {
    _presentCount = 0;
    _absentCount = 0;
    _lateCount = 0;
    _dailySummary = {};
    
    for (var record in data) {
      final status = record['status'];
      if (status == 'present') _presentCount++;
      else if (status == 'absent') _absentCount++;
      else if (status == 'late') _lateCount++;
      
      // Group by date and class for daily summary
      final date = record['date'];
      final classInfo = record['classId'];
      if (date != null && classInfo != null) {
        final dateKey = DateTime.parse(date).toString().split(' ')[0];
        final classKey = '${classInfo['className']} ${classInfo['section']}';
        final key = '$dateKey|$classKey';
        
        if (!_dailySummary.containsKey(key)) {
          _dailySummary[key] = {'present': 0, 'total': 0};
        }
        
        _dailySummary[key]!['total'] = (_dailySummary[key]!['total'] ?? 0) + 1;
        if (status == 'present') {
          _dailySummary[key]!['present'] = (_dailySummary[key]!['present'] ?? 0) + 1;
        }
      }
    }
    
    _totalStudents = data.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Attendance Reports'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filters Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by student name...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip(
                      icon: Icons.calendar_today,
                      label: 'Date Range',
                      color: const Color(0xFFBA78FC),
                      onTap: _selectDateRange,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      icon: Icons.class_,
                      label: 'Class',
                      color: Colors.grey[600]!,
                      onTap: _selectClass,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Summary Cards Section - All in One Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Present',
                    value: '${_presentPercentage.toStringAsFixed(0)}%',
                    valueColor: const Color(0xFF28A745),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Absent',
                    value: '${_absentPercentage.toStringAsFixed(0)}%',
                    valueColor: const Color(0xFFDC3545),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Late',
                    value: '$_lateCount',
                    valueColor: const Color(0xFFFFC107),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Daily Summary Section
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Daily Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _dailySummary.isEmpty
                            ? const Center(
                                child: Text(
                                  'No attendance data available',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _dailySummary.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final key = _dailySummary.keys.elementAt(index);
                                  final parts = key.split('|');
                                  final date = parts[0];
                                  final className = parts[1];
                                  final stats = _dailySummary[key]!;
                                  
                                  return _buildDailySummaryCard({
                                    'className': className,
                                    'date': _formatDate(DateTime.parse(date)),
                                    'present': stats['present'] ?? 0,
                                    'total': stats['total'] ?? 0,
                                  });
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadReport,
        backgroundColor: const Color(0xFFBA78FC),
        child: const Icon(Icons.download),
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummaryCard(Map<String, dynamic> item) {
    final int present = item['present'];
    final int total = item['total'];
    final bool isFullAttendance = present == total;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['className'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['date'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                'Present: $present/$total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isFullAttendance 
                      ? const Color(0xFF28A745) 
                      : const Color(0xFFDC3545),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _viewDetailedReport(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA78FC).withOpacity(0.2),
                foregroundColor: const Color(0xFFBA78FC),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Detailed Report',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFBA78FC),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadAttendanceData();
    }
  }

  void _selectClass() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Class',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: const Text('All Classes'),
                        selected: _selectedClassId == null,
                        onTap: () {
                          setState(() => _selectedClassId = null);
                          Navigator.pop(context);
                          _loadAttendanceData();
                        },
                      ),
                      ..._classes.map((cls) {
                        final classId = cls['_id'];
                        final className = '${cls['className']} ${cls['section']}';
                        return ListTile(
                          title: Text(className),
                          selected: _selectedClassId == classId,
                          onTap: () {
                            setState(() => _selectedClassId = classId);
                            Navigator.pop(context);
                            _loadAttendanceData();
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _viewDetailedReport(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentAttendanceDetailScreen(
          classId: _selectedClassId,
          className: item['className'],
          startDate: _startDate,
          endDate: _endDate,
        ),
      ),
    );
  }

  void _downloadReport() {
    // TODO: Implement report download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading attendance report...'),
        backgroundColor: Color(0xFF28A745),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
