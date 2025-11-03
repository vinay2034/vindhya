import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';
import '../../utils/constants.dart';
import 'student_registration_screen.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = getIt<ApiService>();
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  List<dynamic> _students = [];
  List<dynamic> _filteredStudents = [];
  List<dynamic> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load students and classes in parallel
      final results = await Future.wait([
        _apiService.get(ApiConfig.students),
        _apiService.get(ApiConfig.classes),
      ]);

      final studentsData = results[0].data;
      final classesData = results[1].data;

      if (studentsData['status'] == 'success' && classesData['status'] == 'success') {
        setState(() {
          _students = studentsData['data']['students'] ?? [];
          _classes = classesData['data']['classes'] ?? [];
          _filteredStudents = _students;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _filterStudents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStudents = _students;
      } else {
        _filteredStudents = _students.where((student) {
          final name = student['name']?.toString().toLowerCase() ?? '';
          final rollNumber = student['rollNumber']?.toString().toLowerCase() ?? '';
          final studentId = student['studentId']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower) || 
                 rollNumber.contains(searchLower) ||
                 studentId.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showAddEditDialog({Map<String, dynamic>? studentData}) {
    final isEdit = studentData != null;
    final nameController = TextEditingController(text: studentData?['name'] ?? '');
    final rollNumberController = TextEditingController(text: studentData?['rollNumber'] ?? '');
    final admissionNumberController = TextEditingController(text: studentData?['admissionNumber'] ?? '');
    final dateOfBirthController = TextEditingController(
      text: studentData?['dateOfBirth']?.toString().split('T')[0] ?? ''
    );
    final addressController = TextEditingController(text: studentData?['address'] ?? '');
    final fatherNameController = TextEditingController(
      text: studentData?['emergencyContact']?['fatherName'] ?? ''
    );
    final motherNameController = TextEditingController(
      text: studentData?['emergencyContact']?['motherName'] ?? ''
    );
    final mobileNoController = TextEditingController(
      text: studentData?['emergencyContact']?['phone'] ?? ''
    );
    
    String? selectedClassId;
    if (studentData?['classId'] != null) {
      if (studentData!['classId'] is String) {
        selectedClassId = studentData['classId'];
      } else {
        selectedClassId = studentData['classId']?['_id'];
      }
    }
    String selectedGender = studentData?['gender'] ?? 'male';
    String? selectedBloodGroup = (studentData?['bloodGroup']?.isEmpty ?? true) ? null : studentData?['bloodGroup'];
    File? selectedPhoto;
    String? existingPhotoUrl = studentData?['avatar'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Student' : 'Add New Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Photo picker
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setDialogState(() {
                        selectedPhoto = File(image.path);
                      });
                    }
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: selectedPhoto != null
                        ? ClipOval(
                            child: Image.file(
                              selectedPhoto!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : existingPhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  '${ApiConfig.baseUrl.replaceAll('/api', '')}$existingPhotoUrl',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 60),
                                ),
                              )
                            : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to ${selectedPhoto != null || existingPhotoUrl != null ? 'change' : 'add'} photo',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g., Ananya Sharma',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: rollNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Roll Number *',
                    hintText: 'e.g., 001',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedClassId,
                  decoration: const InputDecoration(
                    labelText: 'Class *',
                    border: OutlineInputBorder(),
                  ),
                  items: _classes.map<DropdownMenuItem<String>>((classItem) {
                    return DropdownMenuItem<String>(
                      value: classItem['_id'],
                      child: Text('${classItem['className']} - ${classItem['section']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedClassId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: admissionNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Admission Number *',
                    hintText: 'e.g., ADM2024001',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateOfBirthController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth *',
                    hintText: 'YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dateOfBirthController.text = date.toIso8601String().split('T')[0];
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender *',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'male', child: Text('Male')),
                    const DropdownMenuItem(value: 'female', child: Text('Female')),
                    const DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedGender = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'A+', child: Text('A+')),
                    DropdownMenuItem(value: 'A-', child: Text('A-')),
                    DropdownMenuItem(value: 'B+', child: Text('B+')),
                    DropdownMenuItem(value: 'B-', child: Text('B-')),
                    DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                    DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                    DropdownMenuItem(value: 'O+', child: Text('O+')),
                    DropdownMenuItem(value: 'O-', child: Text('O-')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedBloodGroup = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter full address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                const Divider(),
                const Text(
                  'Parent/Guardian Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFba78fc),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fatherNameController,
                  decoration: const InputDecoration(
                    labelText: "Father's Name",
                    hintText: "Enter father's full name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: motherNameController,
                  decoration: const InputDecoration(
                    labelText: "Mother's Name",
                    hintText: "Enter mother's full name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mobileNoController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number *',
                    hintText: '10-digit mobile number',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    helperText: 'Will be used to create parent login account',
                  ),
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
                print('=== STUDENT FORM SUBMISSION ===');
                print('Name: ${nameController.text}');
                print('Roll Number: ${rollNumberController.text}');
                print('Admission Number: ${admissionNumberController.text}');
                print('Class ID: $selectedClassId');
                print('DOB: ${dateOfBirthController.text}');
                print('Gender: $selectedGender');
                
                // Validate required fields
                if (nameController.text.isEmpty || 
                    rollNumberController.text.isEmpty ||
                    admissionNumberController.text.isEmpty ||
                    selectedClassId == null ||
                    dateOfBirthController.text.isEmpty ||
                    mobileNoController.text.isEmpty) {
                  print('Validation failed!');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all required fields (Name, Roll Number, Admission Number, Class, Date of Birth, Mobile Number)'),
                    ),
                  );
                  return;
                }

                // Validate mobile number format
                if (mobileNoController.text.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobileNoController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid 10-digit mobile number'),
                    ),
                  );
                  return;
                }

                try {
                  String? parentIdToUse;
                  
                  // Create parent account automatically (not when editing)
                  if (!isEdit) {
                    try {
                      // Prepare parent name (use father's name, or mother's, or default)
                      String parentName = fatherNameController.text.trim().isNotEmpty 
                          ? fatherNameController.text.trim()
                          : (motherNameController.text.trim().isNotEmpty 
                              ? motherNameController.text.trim()
                              : 'Parent of ${nameController.text.trim()}');
                      
                      final parentData = {
                        'email': '${mobileNoController.text.trim()}@parent.school.com',
                        'password': mobileNoController.text.trim(), // Mobile number as password
                        'role': 'parent',
                        'profile': {
                          'name': parentName,
                          'phone': mobileNoController.text.trim(),
                          'address': addressController.text.trim(),
                        }
                      };
                      
                      print('Creating parent account: ${parentData['email']}');
                      final parentResponse = await _apiService.post(
                        ApiConfig.users,
                        data: parentData,
                      );
                      
                      if (parentResponse.data['status'] == 'success') {
                        parentIdToUse = parentResponse.data['data']['user']['_id'];
                        print('Parent created with ID: $parentIdToUse');
                      }
                    } catch (parentError) {
                      print('Error creating parent: $parentError');
                      // Check if parent already exists
                      if (parentError.toString().contains('E11000') || 
                          parentError.toString().contains('duplicate') ||
                          parentError.toString().contains('already exists')) {
                        // Try to find existing parent by email
                        try {
                          final existingParent = await _apiService.get(
                            '${ApiConfig.users}?email=${mobileNoController.text.trim()}@parent.school.com',
                          );
                          if (existingParent.data['data']['users'].isNotEmpty) {
                            parentIdToUse = existingParent.data['data']['users'][0]['_id'];
                            print('Using existing parent ID: $parentIdToUse');
                          }
                        } catch (e) {
                          print('Error finding existing parent: $e');
                        }
                      }
                    }
                  }
                  
                  final data = {
                    'name': nameController.text.trim(),
                    'rollNumber': rollNumberController.text.trim(),
                    'admissionNumber': admissionNumberController.text.trim(),
                    'classId': selectedClassId,
                    'dateOfBirth': dateOfBirthController.text,
                    'gender': selectedGender.toLowerCase(),
                    'address': addressController.text.trim(),
                    'emergencyContact': {
                      'name': fatherNameController.text.trim().isNotEmpty 
                          ? fatherNameController.text.trim()
                          : motherNameController.text.trim(),
                      'phone': mobileNoController.text.trim(),
                      'relation': 'Parent',
                      'fatherName': fatherNameController.text.trim(),
                      'motherName': motherNameController.text.trim(),
                    }
                  };
                  
                  // Add optional fields only if they have values
                  if (selectedBloodGroup != null && selectedBloodGroup!.isNotEmpty) {
                    data['bloodGroup'] = selectedBloodGroup;
                  }
                  
                  if (parentIdToUse != null && parentIdToUse.isNotEmpty) {
                    data['parentId'] = parentIdToUse;
                  }
                  
                  print('Data to send: $data');

                  Response response;
                  if (isEdit) {
                    response = await _apiService.put(
                      '${ApiConfig.students}/${studentData['_id']}',
                      data: data,
                    );
                  } else {
                    response = await _apiService.post(ApiConfig.students, data: data);
                  }
                  
                  // Upload photo if selected
                  if (selectedPhoto != null) {
                    try {
                      final studentId = isEdit 
                          ? studentData['_id'] 
                          : response.data['data']['student']['_id'];
                      
                      final formData = FormData.fromMap({
                        'photo': await MultipartFile.fromFile(
                          selectedPhoto!.path,
                          filename: 'student_${studentId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                        ),
                      });
                      
                      await _apiService.post(
                        '${ApiConfig.students}/$studentId/photo',
                        data: formData,
                      );
                    } catch (photoError) {
                      print('Error uploading photo: $photoError');
                      // Continue even if photo upload fails
                    }
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'Student updated successfully' : 'Student added successfully'
                        ),
                      ),
                    );
                    _loadData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteStudent(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.delete('${ApiConfig.students}/$id');
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student deleted successfully')),
                  );
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Student Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Student Roster'),
            Tab(text: 'Class Assignments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentRosterTab(),
          _buildClassAssignmentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentRegistrationScreen(),
            ),
          );
          if (result == true) {
            _loadData(); // Reload data after successful registration
          }
        },
        backgroundColor: const Color(0xFFba78fc),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStudentRosterTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterStudents,
            decoration: InputDecoration(
              hintText: 'Search by name or ID...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
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
        ),

        // Students List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredStudents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No students found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = _filteredStudents[index];
                        final classInfo = student['classId'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFFba78fc).withOpacity(0.1),
                              backgroundImage: student['avatar'] != null
                                  ? NetworkImage(
                                      '${ApiConfig.baseUrl.replaceAll('/api', '')}${student['avatar']}',
                                    )
                                  : null,
                              child: student['avatar'] == null
                                  ? Text(
                                      student['name']?.substring(0, 1).toUpperCase() ?? 'S',
                                      style: const TextStyle(
                                        color: Color(0xFFba78fc),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              student['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'ID: ${student['studentId'] ?? student['rollNumber'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  classInfo != null 
                                      ? 'Grade: ${classInfo['className']} ${classInfo['section']}'
                                      : 'Grade: Not assigned',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showAddEditDialog(studentData: student);
                                } else if (value == 'delete') {
                                  _deleteStudent(
                                    student['_id'],
                                    student['name'] ?? 'Unknown',
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildClassAssignmentsTab() {
    // Group students by class
    final Map<String, List<dynamic>> studentsByClass = {};
    for (var student in _students) {
      final classId = student['classId']?['_id'] ?? 'unassigned';
      if (!studentsByClass.containsKey(classId)) {
        studentsByClass[classId] = [];
      }
      studentsByClass[classId]!.add(student);
    }

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _classes.length + (studentsByClass.containsKey('unassigned') ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _classes.length) {
                final classItem = _classes[index];
                final classId = classItem['_id'];
                final studentsInClass = studentsByClass[classId] ?? [];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFba78fc).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Color(0xFFba78fc),
                      ),
                    ),
                    title: Text(
                      '${classItem['className']} - ${classItem['section']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${studentsInClass.length} students'),
                    children: studentsInClass.isEmpty
                        ? [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No students in this class',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          ]
                        : studentsInClass.map((student) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: Text(
                                  student['name']?.substring(0, 1).toUpperCase() ?? 'S',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(student['name'] ?? 'Unknown'),
                              subtitle: Text('ID: ${student['studentId'] ?? student['rollNumber'] ?? 'N/A'}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showAddEditDialog(studentData: student),
                              ),
                            );
                          }).toList(),
                  ),
                );
              } else {
                // Unassigned students
                final unassignedStudents = studentsByClass['unassigned'] ?? [];
                if (unassignedStudents.isEmpty) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                      ),
                    ),
                    title: const Text(
                      'Unassigned Students',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${unassignedStudents.length} students'),
                    children: unassignedStudents.map((student) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: Text(
                            student['name']?.substring(0, 1).toUpperCase() ?? 'S',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(student['name'] ?? 'Unknown'),
                        subtitle: const Text('No class assigned'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showAddEditDialog(studentData: student),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }
            },
          );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
