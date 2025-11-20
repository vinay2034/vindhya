import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../dependency_injection.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final ApiService _apiService = getIt<ApiService>();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final nameController = TextEditingController();
  final rollNumberController = TextEditingController();
  final admissionNumberController = TextEditingController();
  final samagraIdController = TextEditingController();
  final addressController = TextEditingController();
  final fatherNameController = TextEditingController();
  final motherNameController = TextEditingController();
  final mobileController = TextEditingController();
  
  // State variables
  List<dynamic> _classes = [];
  String? selectedClassId;
  DateTime? selectedDate;
  String selectedGender = 'male';
  String? selectedBloodGroup;
  File? selectedPhoto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    try {
      final response = await _apiService.get(ApiConfig.classes);
      setState(() {
        _classes = response.data['data']['classes'] ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading classes: $e')),
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
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _registerStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class')),
      );
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
      // Step 1: Create parent account using mobile number
      String parentName = fatherNameController.text.trim().isNotEmpty 
          ? fatherNameController.text.trim()
          : (motherNameController.text.trim().isNotEmpty 
              ? motherNameController.text.trim()
              : 'Parent of ${nameController.text.trim()}');
      
      String? parentIdToUse;
      
      final parentData = {
        'email': '${mobileController.text.trim()}@parent.temp',
        'username': mobileController.text.trim(), // Mobile as username
        'password': mobileController.text.trim(), // Mobile as password
        'role': 'parent',
        'profile': {
          'name': parentName,
          'phone': mobileController.text.trim(),
        }
      };

      try {
        final parentResponse = await _apiService.post(
          ApiConfig.users,
          data: parentData,
        );
        parentIdToUse = parentResponse.data['data']['user']['_id'];
      } catch (e) {
        if (e.toString().contains('already exists') || 
            e.toString().contains('duplicate') ||
            e.toString().contains('E11000')) {
          // Parent already exists, fetch existing parent
          final usersResponse = await _apiService.get(
            '${ApiConfig.users}?role=parent&phone=${mobileController.text.trim()}',
          );
          final users = usersResponse.data['data']['users'] as List;
          if (users.isNotEmpty) {
            parentIdToUse = users[0]['_id'];
          }
        } else {
          rethrow;
        }
      }

      // Step 2: Create student
      final studentData = {
        'name': nameController.text.trim(),
        'rollNumber': rollNumberController.text.trim(),
        'admissionNumber': admissionNumberController.text.trim(),
        'classId': selectedClassId,
        'dateOfBirth': selectedDate!.toIso8601String(),
        'gender': selectedGender,
        'bloodGroup': selectedBloodGroup ?? '',
        'address': addressController.text.trim(),
        'samagraId': samagraIdController.text.trim(),
        'parentId': parentIdToUse,
        'emergencyContact': {
          'fatherName': fatherNameController.text.trim(),
          'motherName': motherNameController.text.trim(),
          'phone': mobileController.text.trim(),
        }
      };

      final studentResponse = await _apiService.post(
        ApiConfig.students,
        data: studentData,
      );

      final studentId = studentResponse.data['data']['student']['_id'];

      // Step 3: Upload photo if selected
      if (selectedPhoto != null) {
        final formData = FormData.fromMap({
          'photo': await MultipartFile.fromFile(
            selectedPhoto!.path,
            filename: 'student_photo.jpg',
          ),
        });

        await _apiService.post(
          '${ApiConfig.students}/$studentId/photo',
          data: formData,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Student registered successfully!\n'
              'Parent Login - Mobile: ${mobileController.text.trim()}, Password: ${mobileController.text.trim()}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
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
    rollNumberController.dispose();
    admissionNumberController.dispose();
    samagraIdController.dispose();
    addressController.dispose();
    fatherNameController.dispose();
    motherNameController.dispose();
    mobileController.dispose();
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
          'New Student Registration',
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
                                'Upload Photo',
                                style: TextStyle(
                                  color: Colors.purple.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Tap to select from gallery or take a picture',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Student's Name
                        _buildSimpleTextField(
                          controller: nameController,
                          label: "Student's Name",
                          hint: 'Enter full name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter student name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Roll No.
                        _buildSimpleTextField(
                          controller: rollNumberController,
                          label: 'Roll No.',
                          hint: 'e.g., 25',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Class
                        _buildSimpleDropdown(
                          label: 'Class',
                          value: selectedClassId,
                          hint: 'Select Class',
                          items: _classes.map((cls) {
                            return DropdownMenuItem<String>(
                              value: cls['_id'],
                              child: Text(cls['className'] ?? ''),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedClassId = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Admission No.
                        _buildSimpleTextField(
                          controller: admissionNumberController,
                          label: 'Admission No.',
                          hint: 'Enter admission number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth
                        _buildSimpleDateField(
                          label: 'Date of Birth',
                          selectedDate: selectedDate,
                          onTap: () => _selectDate(context),
                        ),
                        const SizedBox(height: 16),

                        // Gender
                        _buildSimpleDropdown(
                          label: 'Gender',
                          value: selectedGender,
                          hint: 'Select Gender',
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Male')),
                            DropdownMenuItem(value: 'female', child: Text('Female')),
                            DropdownMenuItem(value: 'other', child: Text('Other')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedGender = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Blood Group
                        _buildSimpleDropdown(
                          label: 'Blood Group',
                          value: selectedBloodGroup,
                          hint: 'Select Group',
                          items: const [
                            DropdownMenuItem(value: null, child: Text('Select Group')),
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
                        _buildSimpleTextField(
                          controller: addressController,
                          label: 'Address',
                          hint: 'Enter permanent address',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        // Samagra ID
                        _buildSimpleTextField(
                          controller: samagraIdController,
                          label: 'Samagra ID',
                          hint: 'Enter Samagra ID',
                        ),
                        const SizedBox(height: 16),

                        // Father's Name
                        _buildSimpleTextField(
                          controller: fatherNameController,
                          label: "Father's Name",
                          hint: "Enter father's full name",
                        ),
                        const SizedBox(height: 16),

                        // Mother's Name
                        _buildSimpleTextField(
                          controller: motherNameController,
                          label: "Mother's Name",
                          hint: "Enter mother's full name",
                        ),
                        const SizedBox(height: 16),

                        // Mobile Number
                        _buildSimpleTextField(
                          controller: mobileController,
                          label: 'Mobile Number',
                          hint: 'Enter primary contact number',
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
                            onPressed: _isLoading ? null : _registerStudent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Register Student',
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

  // Simple text field builder
  Widget _buildSimpleTextField({
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

  // Simple dropdown builder
  Widget _buildSimpleDropdown<T>({
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

  // Simple date field builder
  Widget _buildSimpleDateField({
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
                      ? DateFormat('MM/dd/yyyy').format(selectedDate)
                      : 'mm/dd/yyyy',
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

}
