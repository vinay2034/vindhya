import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';
import '../../utils/constants.dart';
import 'student_details_screen.dart';

class ClassStudentsScreen extends StatefulWidget {
  const ClassStudentsScreen({super.key});

  @override
  State<ClassStudentsScreen> createState() => _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends State<ClassStudentsScreen> {
  final ApiService _apiService = getIt<ApiService>();

  List<Map<String, dynamic>> _classes = [];
  List<Map<String, dynamic>> _students = [];
  String? _selectedClassId;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final classesResponse = await _apiService.get('/teacher/classes');
      final classesData = classesResponse.data['data'];
      
      final classes = List<Map<String, dynamic>>.from(
        classesData is List ? classesData : []
      );

      setState(() {
        _classes = classes;
        if (_classes.isNotEmpty) {
          _selectedClassId = _classes[0]['_id'];
        }
        _isLoading = false;
      });

      if (_selectedClassId != null) {
        await _loadStudents();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading classes: $e')),
        );
      }
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedClassId == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/teacher/students/$_selectedClassId');
      final students = List<Map<String, dynamic>>.from(
        response.data['data']['students'] ?? []
      );

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    
    return _students.where((student) {
      final name = (student['name'] ?? '').toString().toLowerCase();
      final rollNumber = (student['rollNumber'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || rollNumber.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Students',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Class Selector
          if (_classes.isNotEmpty) _buildClassSelector(),

          // Search Bar
          _buildSearchBar(),

          // Students List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _classes.map((classData) {
            final isSelected = _selectedClassId == classData['_id'];
            final className = classData['className'] ?? 'Class';
            final grade = classData['grade'] ?? '';
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$className - Grade $grade'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedClassId = classData['_id'];
                    });
                    _loadStudents();
                  }
                },
                selectedColor: const Color(0xFFBA78FC),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search students...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    final filteredStudents = _filteredStudents;

    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No students found' : 'No students match your search',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Student Count
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '${filteredStudents.length} Student${filteredStudents.length != 1 ? 's' : ''}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        // Students Grid
        ...filteredStudents.map((student) {
          return _buildStudentCard(student);
        }),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final name = student['name'] ?? 'Student';
    final rollNumber = student['rollNumber'] ?? 'N/A';
    final avatar = student['avatar'];
    final studentId = student['_id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE5B87E),
          backgroundImage: avatar != null && avatar.isNotEmpty
              ? NetworkImage('${ApiConfig.baseUrl.replaceAll('/api', '')}$avatar')
              : null,
          child: avatar == null || avatar.isEmpty
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          'Roll No: $rollNumber',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailsScreen(studentId: studentId),
            ),
          );
        },
      ),
    );
  }
}
