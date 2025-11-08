import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class FeeApprovalsScreen extends StatefulWidget {
  const FeeApprovalsScreen({super.key});

  @override
  State<FeeApprovalsScreen> createState() => _FeeApprovalsScreenState();
}

class _FeeApprovalsScreenState extends State<FeeApprovalsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  List<Map<String, dynamic>> _approvalRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final storageService = StorageService();
    await storageService.init();
    _apiService = ApiService(storageService);
    await _loadApprovalRequests();
  }

  Future<void> _loadApprovalRequests() async {
    setState(() => _isLoading = true);

    try {
      final response = await _apiService.getStudents();
      final List<dynamic> studentsList = response['data']['students'];

      // Generate mock fee approval requests
      _approvalRequests = studentsList.where((student) {
        // Filter to get only some students for approval requests
        return (student['_id'].hashCode % 5) <= 2;
      }).map((student) {
        final random = (student['_id'].hashCode % 3);
        String status;
        String feeType;
        double amount;
        String submittedDate;

        if (random == 0) {
          status = 'Pending';
          feeType = 'Term Fee';
          amount = 500;
          submittedDate = '15 Oct 2023';
        } else if (random == 1) {
          status = 'Approved';
          feeType = 'Annual Fee';
          amount = 2000;
          submittedDate = '12 Oct 2023';
        } else {
          status = 'Rejected';
          feeType = 'Activity Fee';
          amount = 150;
          submittedDate = '10 Oct 2023';
        }

        // Get class info safely
        String className = 'N/A';
        String section = '';
        
        if (student['class'] != null) {
          if (student['class'] is Map) {
            className = student['class']['name'] ?? 'N/A';
          } else if (student['class'] is String) {
            className = student['class'];
          }
        }
        
        if (student['section'] != null) {
          section = student['section'].toString();
        }

        return {
          '_id': student['_id'],
          'studentName': student['name'],
          'class': className,
          'section': section,
          'feeType': feeType,
          'amount': amount,
          'submittedDate': submittedDate,
          'status': status,
        };
      }).toList();

      _applyFilters();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading approval requests: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredRequests = _approvalRequests.where((request) {
      bool matchesSearch = _searchQuery.isEmpty ||
          request['studentName']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      bool matchesStatus = _selectedFilter == 'All' ||
          request['status'].toString().toLowerCase() ==
              _selectedFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleApprove(Map<String, dynamic> request) {
    setState(() {
      request['status'] = 'Approved';
      _applyFilters();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request['studentName']} fee approved successfully!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              request['status'] = 'Pending';
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  void _handleReject(Map<String, dynamic> request) {
    setState(() {
      request['status'] = 'Rejected';
      _applyFilters();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${request['studentName']} fee rejected'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              request['status'] = 'Pending';
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Fee Approvals'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for a student...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildFilterChip('All', Colors.purple),
                      const SizedBox(width: 8),
                      _buildFilterChip('Pending', Colors.orange),
                      const SizedBox(width: 8),
                      _buildFilterChip('Approved', Colors.green),
                      const SizedBox(width: 8),
                      _buildFilterChip('Rejected', Colors.red),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Approval Requests List
                Expanded(
                  child: _filteredRequests.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = _filteredRequests[index];
                            return _buildApprovalCard(request);
                          },
                        ),
                ),
              ],
            ),
    );
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
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> request) {
    final statusColor = _getStatusColor(request['status']);
    final isPending = request['status'] == 'Pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                request['status'].toString().toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Student Name
            Text(
              request['studentName'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Class and Section
            Text(
              request['section'].toString().isEmpty 
                ? 'Class ${request['class']}'
                : 'Class ${request['class']} - Section ${request['section']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 4),

            // Fee Type, Amount, and Date
            Text(
              '${request['feeType']}: ₹${request['amount'].toStringAsFixed(2)} | Submitted: ${request['submittedDate']}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),

            // Action Buttons (only for Pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleReject(request),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _handleApprove(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.purple.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Requests Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no requests matching your current\nfilter. Try selecting a different category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
