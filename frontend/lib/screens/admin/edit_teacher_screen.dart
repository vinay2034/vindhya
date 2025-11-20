import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../dependency_injection.dart';

class EditTeacherScreen extends StatefulWidget {
  final Map<String, dynamic> teacher;

  const EditTeacherScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<EditTeacherScreen> createState() => _EditTeacherScreenState();
}

class _EditTeacherScreenState extends State<EditTeacherScreen> {
  final ApiService _apiService = getIt<ApiService>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _employeeIdController;
  late TextEditingController _designationController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _joiningDateController;
  late TextEditingController _qualificationController;
  late TextEditingController _experienceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.teacher['profile']?['name'] ?? widget.teacher['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.teacher['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.teacher['profile']?['phone'] ?? '',
    );
    _employeeIdController = TextEditingController(
      text: widget.teacher['employeeId'] ?? '',
    );
    _designationController = TextEditingController(
      text: widget.teacher['profile']?['designation'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.teacher['profile']?['address'] ?? '',
    );
    _dobController = TextEditingController(
      text: widget.teacher['profile']?['dateOfBirth'] ?? '',
    );
    _joiningDateController = TextEditingController(
      text: widget.teacher['profile']?['joiningDate'] ?? '',
    );
    _qualificationController = TextEditingController(
      text: widget.teacher['profile']?['qualification'] ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.teacher['profile']?['experience']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _designationController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    _joiningDateController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final teacherId = widget.teacher['_id'];
      
      final updateData = {
        'name': _nameController.text,
        'email': _emailController.text,
        'employeeId': _employeeIdController.text,
        'profile': {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'designation': _designationController.text,
          'address': _addressController.text,
          'dateOfBirth': _dobController.text,
          'joiningDate': _joiningDateController.text,
          'qualification': _qualificationController.text,
          'experience': _experienceController.text.isNotEmpty
              ? int.tryParse(_experienceController.text) ?? 0
              : 0,
        },
      };

      await _apiService.put(
        '/admin/users/$teacherId',
        data: updateData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Teacher details updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating teacher: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Teacher',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFFBA78FC),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information Section
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _employeeIdController,
              label: 'Employee ID',
              icon: Icons.badge_outlined,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter employee ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _designationController,
              label: 'Designation',
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _dobController,
              label: 'Date of Birth',
              icon: Icons.cake_outlined,
              hintText: 'e.g., 15th August, 1985',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _joiningDateController,
              label: 'Date of Joining',
              icon: Icons.calendar_today_outlined,
              hintText: 'e.g., 1st June, 2010',
            ),

            const SizedBox(height: 24),

            // Contact Information Section
            _buildSectionHeader('Contact Information'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.home_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Professional Information Section
            _buildSectionHeader('Professional Information'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _qualificationController,
              label: 'Qualification',
              icon: Icons.school_outlined,
              hintText: 'e.g., M.Sc Mathematics, B.Ed',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _experienceController,
              label: 'Years of Experience',
              icon: Icons.timeline_outlined,
              keyboardType: TextInputType.number,
              hintText: 'e.g., 5',
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBA78FC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFBA78FC),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: const Color(0xFFBA78FC)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFBA78FC), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
