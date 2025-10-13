import 'package:flutter/material.dart';
import '../services/profile/profile_service.dart';
import '../components/components.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _displayNameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _usernameController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
    _phoneController = TextEditingController();
    _usernameController = TextEditingController();
    _locationController = TextEditingController();
    _websiteController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    Map<String, dynamic>? userData = await _profileService.getUserProfile();

    if (userData != null) {
      _displayNameController.text = userData['displayName'] ?? '';
      _bioController.text = userData['bio'] ?? '';
      _phoneController.text = userData['phoneNumber'] ?? '';
      _usernameController.text = userData['username'] ?? '';
      _locationController.text = userData['location'] ?? '';
      _websiteController.text = userData['website'] ?? '';
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      bool allSuccess = true;
      String errorMessage = '';

      // Update display name
      if (_displayNameController.text.isNotEmpty) {
        bool success = await _profileService.updateDisplayName(
          _displayNameController.text,
        );
        if (!success) {
          allSuccess = false;
          errorMessage = 'Failed to update display name';
        }
      }

      // Update username
      if (_usernameController.text.isNotEmpty) {
        bool success = await _profileService.updateUsername(
          _usernameController.text,
        );
        if (!success) {
          allSuccess = false;
          errorMessage = 'Username already taken or update failed';
        }
      }

      // Update bio
      bool bioSuccess = await _profileService.updateBio(_bioController.text);
      if (!bioSuccess) {
        allSuccess = false;
        errorMessage = 'Failed to update bio';
      }

      // Update phone number
      if (_phoneController.text.isNotEmpty) {
        bool success = await _profileService.updatePhoneNumber(
          _phoneController.text,
        );
        if (!success) {
          allSuccess = false;
          errorMessage = 'Failed to update phone number';
        }
      }

      // Update location
      if (_locationController.text.isNotEmpty) {
        bool success = await _profileService.updateLocation(
          _locationController.text,
        );
        if (!success) {
          allSuccess = false;
          errorMessage = 'Failed to update location';
        }
      }

      // Update website
      if (_websiteController.text.isNotEmpty) {
        bool success = await _profileService.updateWebsite(
          _websiteController.text,
        );
        if (!success) {
          allSuccess = false;
          errorMessage = 'Failed to update website';
        }
      }

      if (mounted) {
        if (allSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage.isNotEmpty ? errorMessage : 'Some updates failed',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child:
            _isLoading
                ? ProfileShimmerLoading(
                  isDark: Theme.of(context).brightness == Brightness.dark,
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // Header with back button and save button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.grey,
                            ),
                            if (!_isSaving)
                              TextButton(
                                onPressed: _saveProfile,
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Color(0xFF667eea),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Profile icon in circular container
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Title
                        const Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          "Update your profile information",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Display Name section
                        Text(
                          'Display Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _displayNameController,
                          label: 'Display Name',
                          icon: Icons.person_outline,
                          hint: 'Enter your display name',
                          isDark: isDarkMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a display name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Bio section
                        Text(
                          'Bio',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _bioController,
                          label: 'Bio',
                          icon: Icons.edit_note,
                          hint: 'Tell us about yourself',
                          isDark: isDarkMode,
                          maxLines: 4,
                          maxLength: 200,
                        ),

                        const SizedBox(height: 24),

                        // Phone Number section
                        Text(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          hint: '+1 234 567 8900',
                          isDark: isDarkMode,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 24),

                        // Username section
                        Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          icon: Icons.alternate_email,
                          hint: 'username',
                          isDark: isDarkMode,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                return 'Username can only contain letters, numbers, and underscores';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Location section
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _locationController,
                          label: 'Location',
                          icon: Icons.location_on_outlined,
                          hint: 'City, Country',
                          isDark: isDarkMode,
                        ),

                        const SizedBox(height: 24),

                        // Website section
                        Text(
                          'Website',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _websiteController,
                          label: 'Website',
                          icon: Icons.link,
                          hint: 'https://yourwebsite.com',
                          isDark: isDarkMode,
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!value.startsWith('http://') &&
                                  !value.startsWith('https://')) {
                                return 'Website must start with http:// or https://';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        // Save Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child:
                                _isSaving
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
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
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF667eea)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
