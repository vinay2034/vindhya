import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';
import 'student_details_screen.dart';

class StudentsListScreen extends StatefulWidget {
  final String? selectedClassId;
  const StudentsListScreen({super.key, this.selectedClassId});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final ApiService _apiService = getIt<ApiService>();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _assignedClasses = [];
  Map<String, List<Map<String, dynamic>>> _studentsByClass = {};
  Map<String, bool> _expandedClasses = {};
  String _searchQuery = '';
  bool _isLoading = true;
  final int _currentNavIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadAllStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStudents() async {
    setState(() => _isLoading = true);
    try {
      // Get all assigned classes for this teacher
      final classesResponse = await _apiService.get('/teacher/classes');
      final classesData = classesResponse.data['data'];
      final classes = List<Map<String, dynamic>>.from(
        classesData is List ? classesData : []
      );

      // Load students for each class
      Map<String, List<Map<String, dynamic>>> studentsByClass = {};
      Map<String, bool> expandedClasses = {};
      
      for (var classData in classes) {
        final classId = classData['_id'];
        final className = classData['className'] ?? classData['name'] ?? 'Unknown Class';
        final section = classData['section'] ?? '';
        final fullClassName = section.isNotEmpty ? '$className - $section' : className;
        
        // Expand the selected class by default, or first class if no selection
        expandedClasses[classId] = widget.selectedClassId == classId || 
                                   (widget.selectedClassId == null && studentsByClass.isEmpty);
        
        try {
          final studentsResponse = await _apiService.get('/teacher/students/$classId');
          final studentsData = studentsResponse.data['data'];
          
          // Backend returns { students: [...] }, not just [...]
          final studentsList = studentsData['students'];
          final students = List<Map<String, dynamic>>.from(
            studentsList is List ? studentsList : []
          );
          
          if (students.isNotEmpty) {
            // Add class information to each student
            for (var student in students) {
              student['className'] = fullClassName;
              student['classId'] = classId;
            }
            studentsByClass[classId] = students;
            classData['fullClassName'] = fullClassName;
          }
        } catch (e) {
          print('Error loading students for class $classId: $e');
        }
      }

      setState(() {
        _assignedClasses = classes.where((c) => studentsByClass.containsKey(c['_id'])).toList();
        _studentsByClass = studentsByClass;
        _expandedClasses = expandedClasses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading classes: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredStudents(List<Map<String, dynamic>> students) {
    if (_searchQuery.isEmpty) return students;
    
    final searchLower = _searchQuery.toLowerCase();
    return students.where((student) {
      return student['name']?.toString().toLowerCase().contains(searchLower) == true ||
             student['rollNumber']?.toString().toLowerCase().contains(searchLower) == true;
    }).toList();
  }

  int _getTotalStudents() {
    int total = 0;
    for (var students in _studentsByClass.values) {
      total += students.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (!_isLoading && _assignedClasses.isNotEmpty)
              _buildSummaryCard(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(
                      color: Color(0xFFBA78FC),
                    ))
                  : _assignedClasses.isEmpty
                      ? _buildEmptyState()
                      : _buildClassWiseStudentsList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Students',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search student name or roll no.',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBA78FC)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalStudents = _getTotalStudents();
    final totalClasses = _assignedClasses.length;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBA78FC), Color(0xFF9D5FD8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBA78FC).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(Icons.class_, totalClasses.toString(), 'Classes'),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildSummaryItem(Icons.people, totalStudents.toString(), 'Students'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassWiseStudentsList() {
    return RefreshIndicator(
      onRefresh: _loadAllStudents,
      color: const Color(0xFFBA78FC),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _assignedClasses.length,
        itemBuilder: (context, index) {
          final classData = _assignedClasses[index];
          final classId = classData['_id'];
          final className = classData['fullClassName'] ?? 'Unknown Class';
          final students = _studentsByClass[classId] ?? [];
          final filteredStudents = _getFilteredStudents(students);
          final isExpanded = _expandedClasses[classId] ?? false;

          return _buildClassCard(
            classId,
            className,
            filteredStudents,
            students.length,
            isExpanded,
          );
        },
      ),
    );
  }

  Widget _buildClassCard(
    String classId,
    String className,
    List<Map<String, dynamic>> filteredStudents,
    int totalStudents,
    bool isExpanded,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedClasses[classId] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBA78FC).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.class_,
                      color: Color(0xFFBA78FC),
                      size: 24,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalStudents student${totalStudents != 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            if (filteredStudents.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _searchQuery.isEmpty
                      ? 'No students in this class'
                      : 'No students match your search',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filteredStudents.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 72,
                  color: Colors.grey.shade100,
                ),
                itemBuilder: (context, index) {
                  return _buildStudentCard(filteredStudents[index]);
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final name = student['name'] ?? 'Unknown';
    final rollNumber = student['rollNumber'] ?? 'N/A';
    final studentId = student['_id'];
    
    // Get first letter for avatar
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    
    return InkWell(
      onTap: () {
        if (studentId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailsScreen(
                studentId: studentId,
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBA78FC), Color(0xFF9D5FD8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and Roll Number
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Roll: $rollNumber',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade300,
              size: 20,
            ),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Classes Assigned',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You don\'t have any classes assigned yet.\nPlease contact the administrator.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFBA78FC),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        currentIndex: _currentNavIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index != 1) { // Not Students tab
            Navigator.pop(context); // Go back to dashboard first
            
            // Then navigate based on index
            if (index == 0) {
              // Already on dashboard after pop
            } else if (index == 3) {
              // Navigate to profile
              // Will be handled by dashboard
            }
          }
        },
      ),
    );
  }
}
