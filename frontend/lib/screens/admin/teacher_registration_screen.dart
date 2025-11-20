import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../dependency_injection.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  const TeacherRegistrationScreen({super.key});

  @override
  State<TeacherRegistrationScreen> createState() => _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  final ApiService _apiService = getIt<ApiService>();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final nameController = TextEditingController();
  final employeeIdController = TextEditingController();
  final addressController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  
  // State variables
  List<dynamic> _subjects = [];
  List<dynamic> _classes = [];
  List<String> selectedSubjects = [];
  List<String> selectedClasses = [];
  DateTime? selectedDate;
  String selectedGender = 'male';
  String? selectedBloodGroup;
  File? selectedPhoto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _apiService.get(ApiConfig.subjects),
        _apiService.get(ApiConfig.classes),
      ]);

      setState(() {
        _subjects = results[0].data['data']['subjects'] ?? [];
        _classes = results[1].data['data']['classes'] ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        selectedPhoto = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _registerTeacher() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Create teacher user account
      final teacherData = {
        'email': emailController.text.trim(),
        'password': 'teacher123', // Default password for all teachers
        'role': 'teacher',
        'employeeId': employeeIdController.text.trim(),
        'profile': {
          'name': nameController.text.trim(),
          'phone': mobileController.text.trim(),
          'address': addressController.text.trim(),
          'dateOfBirth': selectedDate!.toIso8601String(),
          'gender': selectedGender,
        }
      };

      final teacherResponse = await _apiService.post(
        ApiConfig.users,
        data: teacherData,
      );

      final teacherId = teacherResponse.data['data']['user']['_id'];

      // Step 2: Upload photo if selected
      if (selectedPhoto != null) {
        try {
          final formData = FormData.fromMap({
            'avatar': await MultipartFile.fromFile(
              selectedPhoto!.path,
              filename: 'teacher_photo.jpg',
            ),
          });

          await _apiService.put(
            '${ApiConfig.users}/$teacherId',
            data: formData,
          );
        } catch (e) {
          print('Photo upload failed: $e');
        }
      }

      // Step 3: Assign subjects and classes
      if (selectedSubjects.isNotEmpty || selectedClasses.isNotEmpty) {
        try {
          await _apiService.put(
            '${ApiConfig.users}/$teacherId',
            data: {
              'subjectsTaught': selectedSubjects,
              'assignedClasses': selectedClasses,
            },
          );
        } catch (e) {
          print('Assignment update failed: $e');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Teacher registered successfully!\n'
              'Email: ${emailController.text.trim()}\n'
              'Default Password: teacher123',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    employeeIdController.dispose();
    addressController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Teacher',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Photo Upload Section
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.purple.shade200,
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                    color: Colors.purple.shade50,
                                  ),
                                  child: selectedPhoto != null
                                      ? ClipOval(
                                          child: Image.file(
                                            selectedPhoto!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.camera_alt,
                                          size: 40,
                                          color: Colors.purple.shade300,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  color: Colors.purple.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Full Name
                        _buildTextField(
                          controller: nameController,
                          label: 'Full Name',
                          hint: "Enter teacher's full name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter teacher name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Employee ID
                        _buildTextField(
                          controller: employeeIdController,
                          label: 'Employee ID',
                          hint: 'Enter employee ID',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Employee ID is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth
                        _buildDateField(
                          label: 'Date of Birth',
                          selectedDate: selectedDate,
                          onTap: () => _selectDate(context),
                        ),
                        const SizedBox(height: 16),

                        // Gender
                        _buildGenderField(),
                        const SizedBox(height: 16),

                        // Blood Group
                        _buildDropdown(
                          label: 'Blood Group',
                          value: selectedBloodGroup,
                          hint: 'Select Blood Group',
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Select Blood Group')),
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
                            setState(() {
                              selectedBloodGroup = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Address
                        _buildTextField(
                          controller: addressController,
                          label: 'Address',
                          hint: 'Enter permanent address',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Mobile
                        _buildTextField(
                          controller: mobileController,
                          label: 'Mobile',
                          hint: 'Enter mobile number',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Mobile number is required';
                            }
                            if (value.length != 10) {
                              return 'Enter valid 10-digit mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          hint: 'Enter email address',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Enter valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Subjects Taught
                        _buildSubjectsField(),
                        const SizedBox(height: 16),

                        // Assigned Classes
                        _buildClassesField(),
                        const SizedBox(height: 24),

                        // Register Button
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple.shade400, Colors.purple.shade600],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _registerTeacher,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Register Teacher',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple.shade400, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple.shade400, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate)
                      : 'Select date',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black87 : Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton('Male', 'male'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton('Female', 'female'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton('Other', 'other'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String label, String value) {
    final isSelected = selectedGender == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.purple.shade400 : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.purple.shade700 : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subjects Taught',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedSubjects.map((subjectId) {
              final subject = _subjects.firstWhere(
                (s) => s['_id'] == subjectId,
                orElse: () => {'name': 'Unknown'},
              );
              return Chip(
                label: Text(subject['name'] ?? 'Unknown'),
                backgroundColor: Colors.purple.shade100,
                deleteIconColor: Colors.purple.shade700,
                onDeleted: () {
                  setState(() {
                    selectedSubjects.remove(subjectId);
                  });
                },
              );
            }),
            InkWell(
              onTap: () => _showSubjectSelector(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Add subject...',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assigned Classes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...selectedClasses.map((classId) {
              final cls = _classes.firstWhere(
                (c) => c['_id'] == classId,
                orElse: () => {'className': 'Unknown'},
              );
              return Chip(
                label: Text(cls['className'] ?? 'Unknown'),
                backgroundColor: Colors.purple.shade100,
                deleteIconColor: Colors.purple.shade700,
                onDeleted: () {
                  setState(() {
                    selectedClasses.remove(classId);
                  });
                },
              );
            }),
            InkWell(
              onTap: () => _showClassSelector(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Add class...',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showSubjectSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Subjects'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _subjects.map((subject) {
              final isSelected = selectedSubjects.contains(subject['_id']);
              return CheckboxListTile(
                title: Text(subject['name'] ?? 'Unknown'),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedSubjects.add(subject['_id']);
                    } else {
                      selectedSubjects.remove(subject['_id']);
                    }
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClassSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Classes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _classes.map((cls) {
              final isSelected = selectedClasses.contains(cls['_id']);
              return CheckboxListTile(
                title: Text(cls['className'] ?? 'Unknown'),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedClasses.add(cls['_id']);
                    } else {
                      selectedClasses.remove(cls['_id']);
                    }
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
