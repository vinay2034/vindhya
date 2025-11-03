import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';

class FeesManagementScreen extends StatefulWidget {
  const FeesManagementScreen({Key? key}) : super(key: key);

  @override
  State<FeesManagementScreen> createState() => _FeesManagementScreenState();
}

class _FeesManagementScreenState extends State<FeesManagementScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = getIt<ApiService>();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<dynamic> _fees = [];
  List<dynamic> _filteredFees = [];
  List<dynamic> _students = [];
  Map<String, dynamic> _summary = {};

  bool _isLoading = true;
  String _selectedAcademicYear = '2024-2025';
  String _selectedStatus = 'all'; // all, paid, pending, overdue

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _searchController.addListener(_filterFees);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _apiService.get('/admin/fees',
            queryParameters: {'academicYear': _selectedAcademicYear}),
        _apiService.get('/admin/students'),
      ]);

      setState(() {
        _fees = results[0].data['data']['fees'] ?? [];
        _students = results[1].data['data']['students'] ?? [];
        _calculateSummary();
        _filteredFees = _fees;
      });
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateSummary() {
    double totalCollected = 0;
    double outstanding = 0;
    double overdue = 0;

    for (final fee in _fees) {
      final paidAmount = (fee['paidAmount'] ?? 0).toDouble();
      final amount = (fee['amount'] ?? 0).toDouble();
      final status = fee['status'];

      totalCollected += paidAmount;

      if (status == 'pending' || status == 'partial') {
        outstanding += (amount - paidAmount);
      }

      if (status == 'overdue') {
        overdue += (amount - paidAmount);
      }
    }

    _summary = {
      'collected': totalCollected,
      'outstanding': outstanding,
      'overdue': overdue,
    };
  }

  void _filterFees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFees = _fees.where((fee) {
        final studentName = fee['studentId']?['name']?.toLowerCase() ?? '';
        final rollNumber = fee['studentId']?['rollNumber']?.toLowerCase() ?? '';
        final matchesSearch =
            studentName.contains(query) || rollNumber.contains(query);

        if (_selectedStatus == 'all') return matchesSearch;
        return matchesSearch && fee['status'] == _selectedStatus;
      }).toList();
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? fee}) {
    final isEdit = fee != null;
    String? selectedStudentId = fee?['studentId']?['_id'];
    String selectedFeeType = fee?['feeType'] ?? 'tuition';
    String selectedStatus = fee?['status'] ?? 'pending';
    double amount = (fee?['amount'] ?? 0).toDouble();
    double paidAmount = (fee?['paidAmount'] ?? 0).toDouble();
    DateTime dueDate =
        fee?['dueDate'] != null ? DateTime.parse(fee!['dueDate']) : DateTime.now();
    DateTime? paymentDate = fee?['paymentDate'] != null
        ? DateTime.parse(fee!['paymentDate'])
        : null;
    String remarks = fee?['remarks'] ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Fee Record' : 'Add Fee Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedStudentId,
                  decoration: const InputDecoration(labelText: 'Student *'),
                  items: _students.map<DropdownMenuItem<String>>((student) {
                    return DropdownMenuItem(
                      value: student['_id'],
                      child:
                          Text('${student['name']} (${student['rollNumber']})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedStudentId = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedFeeType,
                  decoration: const InputDecoration(labelText: 'Fee Type'),
                  items: [
                    'tuition',
                    'transport',
                    'library',
                    'sports',
                    'exam',
                    'hostel',
                    'other'
                  ].map((type) {
                    return DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() + type.substring(1)));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedFeeType = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: amount.toString(),
                  decoration: const InputDecoration(labelText: 'Amount *'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      amount = double.tryParse(value) ?? amount,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: paidAmount.toString(),
                  decoration: const InputDecoration(labelText: 'Paid Amount'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      paidAmount = double.tryParse(value) ?? paidAmount,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(_dateFormat.format(dueDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() => dueDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['paid', 'pending', 'overdue', 'partial'].map((status) {
                    return DropdownMenuItem(
                        value: status,
                        child: Text(status[0].toUpperCase() + status.substring(1)));
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedStatus = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: remarks,
                  decoration: const InputDecoration(labelText: 'Remarks'),
                  maxLines: 2,
                  onChanged: (value) => remarks = value,
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
                if (selectedStudentId == null || amount <= 0) {
                  _showError('Please fill all required fields');
                  return;
                }

                final data = {
                  'studentId': selectedStudentId,
                  'feeType': selectedFeeType,
                  'amount': amount,
                  'paidAmount': paidAmount,
                  'dueDate': dueDate.toIso8601String(),
                  'status': selectedStatus,
                  'academicYear': _selectedAcademicYear,
                  if (remarks.isNotEmpty) 'remarks': remarks,
                  if (selectedStatus == 'paid' && paymentDate == null)
                    'paymentDate': DateTime.now().toIso8601String(),
                };

                try {
                  if (isEdit) {
                    await _apiService.put('/admin/fees/${fee['_id']}',
                        data: data);
                  } else {
                    await _apiService.post('/admin/fees', data: data);
                  }

                  Navigator.pop(context);
                  _loadData();
                  _showSuccess(
                    isEdit
                        ? 'Fee record updated successfully'
                        : 'Fee record added successfully',
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

  Future<void> _deleteFee(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Fee Record'),
        content: const Text(
            'Are you sure you want to delete this fee record? This action cannot be undone.'),
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
        await _apiService.delete('/admin/fees/$id');
        _loadData();
        _showSuccess('Fee record deleted successfully');
      } catch (e) {
        _showError('Failed to delete fee record: $e');
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees Management'),
        backgroundColor: const Color(0xFFBA78FC),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Fee Records'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildFeeRecordsTab(),
                _buildReportsTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              backgroundColor: const Color(0xFFBA78FC),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Academic Year Selector
          DropdownButtonFormField<String>(
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
              _loadData();
            },
          ),
          const SizedBox(height: 24),
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Collected',
                  _currencyFormat.format(_summary['collected'] ?? 0),
                  Colors.green,
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Outstanding',
                  _currencyFormat.format(_summary['outstanding'] ?? 0),
                  Colors.orange,
                  Icons.hourglass_empty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Overdue',
                  _currencyFormat.format(_summary['overdue'] ?? 0),
                  Colors.red,
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Students',
                  _students.length.toString(),
                  Colors.blue,
                  Icons.people,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRecordsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by student name or roll number...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text('Filter: '),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedStatus == 'all',
                      onSelected: (selected) {
                        setState(() => _selectedStatus = 'all');
                        _filterFees();
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Paid'),
                      selected: _selectedStatus == 'paid',
                      selectedColor: Colors.green[200],
                      onSelected: (selected) {
                        setState(() => _selectedStatus = 'paid');
                        _filterFees();
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Pending'),
                      selected: _selectedStatus == 'pending',
                      selectedColor: Colors.orange[200],
                      onSelected: (selected) {
                        setState(() => _selectedStatus = 'pending');
                        _filterFees();
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Overdue'),
                      selected: _selectedStatus == 'overdue',
                      selectedColor: Colors.red[200],
                      onSelected: (selected) {
                        setState(() => _selectedStatus = 'overdue');
                        _filterFees();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredFees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No fee records found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredFees.length,
                  itemBuilder: (context, index) {
                    final fee = _filteredFees[index];
                    return _buildFeeCard(fee);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFeeCard(Map<String, dynamic> fee) {
    final status = fee['status'];
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fee['studentId']?['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Roll: ${fee['studentId']?['rollNumber'] ?? 'N/A'}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fee Type',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(
                      fee['feeType']?.toUpperCase() ?? 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(
                      _currencyFormat.format(fee['amount'] ?? 0),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Due Date',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Text(
                      fee['dueDate'] != null
                          ? _dateFormat.format(DateTime.parse(fee['dueDate']))
                          : 'N/A',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showAddEditDialog(fee: fee),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteFee(fee['_id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Detailed reports coming soon',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
