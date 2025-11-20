import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class FeesManagementScreen extends StatefulWidget {
  const FeesManagementScreen({super.key});

  @override
  State<FeesManagementScreen> createState() => _FeesManagementScreenState();
}

class _FeesManagementScreenState extends State<FeesManagementScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  String _selectedFilter = 'All Students';
  String _searchQuery = '';
  
  double _totalOutstanding = 0;
  double _totalCollected = 0;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storageService = StorageService();
    await storageService.init();
    _apiService = ApiService(storageService);
    await _loadStudentsWithFees();
  }

  Future<void> _loadStudentsWithFees() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getStudents();
      final List<dynamic> studentsList = response['data']['students'];

      _students = studentsList.map((student) {
        final random = (student['_id'].hashCode % 5);
        String status;
        double amount;
        
        if (random == 0) {
          status = 'Paid';
          amount = 1200;
        } else if (random == 1) {
          status = 'Overdue';
          amount = 250;
        } else if (random == 2) {
          status = 'Upcoming';
          amount = 1300;
        } else if (random == 3) {
          status = 'Approval';
          amount = 800;
        } else {
          status = 'Paid';
          amount = 1200;
        }

        return {
          '_id': student['_id'],
          'name': student['name'],
          'rollNumber': student['rollNumber'],
          'photo': student['photo'],
          'status': status,
          'amount': amount,
        };
      }).toList();

      _calculateTotals();
      _applyFilters();
      
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading students: ')),
        );
      }
    }
  }

  void _calculateTotals() {
    _totalOutstanding = 0;
    _totalCollected = 0;

    for (var student in _students) {
      if (student['status'] == 'Paid') {
        _totalCollected += student['amount'];
      } else {
        _totalOutstanding += student['amount'];
      }
    }
  }

  void _applyFilters() {
    _filteredStudents = _students.where((student) {
      bool matchesSearch = _searchQuery.isEmpty ||
          student['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student['rollNumber'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesStatus = _selectedFilter == 'All Students' ||
          student['status'] == _selectedFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildFilterChip(String label, Color color) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _applyFilters();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'All Students':
        return Colors.grey[700]!;
      case 'Paid':
        return Colors.green;
      case 'Overdue':
        return Colors.red;
      case 'Upcoming':
        return Colors.orange;
      case 'Approval':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _showPaymentDialog(Map<String, dynamic> student) {
    final isApprovalStatus = student['status'] == 'Approval';
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Payment - ${student['name']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Current Status: ', style: TextStyle(fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(student['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(student['status'])),
                    ),
                    child: Text(
                      student['status'],
                      style: TextStyle(
                        color: _getStatusColor(student['status']),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Amount: ₹${student['amount'].toStringAsFixed(0)}'),
              const SizedBox(height: 16),
              Text(
                isApprovalStatus 
                  ? 'Teacher has marked this payment. Approve to confirm.'
                  : 'Change status to:',
                style: TextStyle(
                  fontSize: 13,
                  color: isApprovalStatus ? Colors.blue[700] : Colors.black87,
                  fontStyle: isApprovalStatus ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            if (isApprovalStatus)
              TextButton(
                onPressed: () {
                  setState(() {
                    student['status'] = 'Paid';
                    _calculateTotals();
                    _applyFilters();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${student['name']} payment approved!'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            student['status'] = 'Approval';
                            _calculateTotals();
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.1),
                ),
                child: const Text('Approve Payment', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              )
            else
              TextButton(
                onPressed: () {
                  setState(() {
                    student['status'] = 'Paid';
                    _calculateTotals();
                    _applyFilters();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${student['name']} marked as Paid'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Mark as Paid'),
              ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Overdue':
        return Colors.red;
      case 'Upcoming':
        return Colors.orange;
      case 'Approval':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.approval),
            tooltip: 'Fee Approvals',
            onPressed: () {
              Navigator.pushNamed(context, '/fee-approvals');
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Outstanding',
                          '₹${_totalOutstanding.toStringAsFixed(0)}',
                          const Color(AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Collected',
                          '₹${_totalCollected.toStringAsFixed(0)}',
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter by Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All Students', _getFilterColor('All Students')),
                            const SizedBox(width: 8),
                            _buildFilterChip('Paid', _getFilterColor('Paid')),
                            const SizedBox(width: 8),
                            _buildFilterChip('Overdue', _getFilterColor('Overdue')),
                            const SizedBox(width: 8),
                            _buildFilterChip('Upcoming', _getFilterColor('Upcoming')),
                            const SizedBox(width: 8),
                            _buildFilterChip('Approval', _getFilterColor('Approval')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search students by name or ID',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_selectedFilter (${_filteredStudents.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'No students found',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredStudents.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            return _buildStudentCard(student);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final statusColor = _getStatusColor(student['status']);
    return InkWell(
      onTap: () => _showPaymentDialog(student),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(AppColors.primary),
              child: Text(
                _getInitials(student['name']),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: #${student['rollNumber'] ?? 'N/A'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    student['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${student['amount'].toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
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
}
