import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth/auth_service.dart';
import '../services/profile/profile_service.dart';
import '../components/profile/profile_components.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _userData;
  Map<String, int> _stats = {'messages': 0, 'contacts': 0, 'groups': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    // Load user profile data
    _userData = await _profileService.getUserProfile();

    // Load user stats
    _stats = await _profileService.getUserStats();

    setState(() => _isLoading = false);
  }

  Future<void> _showImageSourceDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ImageSourceBottomSheet.show(
      context,
      isDark: isDark,
      onGalleryTap: () {
        Navigator.pop(context);
        _pickImageFromGallery();
      },
      onCameraTap: () {
        Navigator.pop(context);
        _pickImageFromCamera();
      },
      onEmojiTap: () {
        Navigator.pop(context);
        _showEmojiSelector();
      },
      onRemoveTap:
          _userData?['hasProfileImage'] == true ||
                  _userData?['emojiAvatar'] != null
              ? () {
                Navigator.pop(context);
                _removeProfileAvatar();
              }
              : null,
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final imageFile = await _profileService.pickImageFromGallery();
      if (imageFile != null) {
        await _uploadImage(imageFile);
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final imageFile = await _profileService.pickImageFromCamera();
      if (imageFile != null) {
        await _uploadImage(imageFile);
      }
    } catch (e) {
      _showErrorSnackBar('Error taking photo: $e');
    }
  }

  Future<void> _showEmojiSelector() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    EmojiSelectorBottomSheet.show(
      context,
      isDark: isDark,
      onEmojiSelected: (emoji) async {
        await _setEmojiAvatar(emoji);
      },
    );
  }

  Future<void> _setEmojiAvatar(String emoji) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _profileService.setEmojiAvatar(emoji);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (success) {
          setState(() {
            _userData?['emojiAvatar'] = emoji;
            _userData?['hasProfileImage'] = false;
          });
          _loadUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Emoji avatar set successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showErrorSnackBar('Failed to set emoji avatar');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar('Error setting emoji avatar: $e');
      }
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      print('Starting image upload...');
      final result = await _profileService.uploadProfileImage(imageFile);

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (result != null) {
          print('Upload successful');
          setState(() {
            _userData?['hasProfileImage'] = true;
          });
          // Reload the page to show new image
          _loadUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          print('Upload failed: result is null');
          _showErrorSnackBar(
            'Failed to upload image. Please check your internet connection or try a smaller image.',
          );
        }
      }
    } catch (e, stackTrace) {
      print('Upload error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showErrorSnackBar('Error uploading image: ${e.toString()}');
      }
    }
  }

  Future<void> _removeProfileAvatar() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Profile Picture'),
            content: const Text(
              'Are you sure you want to remove your profile picture?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Remove both image and emoji
        bool success = false;
        if (_userData?['hasProfileImage'] == true) {
          success = await _profileService.deleteProfileImage();
        } else if (_userData?['emojiAvatar'] != null) {
          success = await _profileService.removeEmojiAvatar();
        }

        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          if (success) {
            setState(() {
              _userData?['hasProfileImage'] = false;
              _userData?['emojiAvatar'] = null;
            });
            _loadUserData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture removed successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            _showErrorSnackBar('Failed to remove avatar');
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          _showErrorSnackBar('Error removing avatar: $e');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );

    // Reload data if profile was updated
    if (result == true) {
      _loadUserData();
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final authService = AuthService();
    final currentUser = authService.getCurrentUser();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUser?.email == null) {
      _showErrorSnackBar('No email associated with this account');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_outlined,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A password reset link will be sent to:',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 20,
                        color: Color(0xFF667eea),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentUser!.email!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667eea),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Please check your email and follow the instructions to reset your password.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Send Reset Link'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await authService.sendPasswordResetEmail(currentUser!.email!);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Password reset link sent! Check your email.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          // Handle specific error codes
          String errorMessage;
          String errorCode = e.toString();

          if (errorCode.contains('user-not-found')) {
            errorMessage = 'No account found with this email address.';
          } else if (errorCode.contains('invalid-email')) {
            errorMessage = 'Invalid email address.';
          } else if (errorCode.contains('network-request-failed')) {
            errorMessage = 'Network error. Please check your connection.';
          } else if (errorCode.contains('too-many-requests')) {
            errorMessage = 'Too many requests. Please try again later.';
          } else {
            errorMessage = 'Failed to send reset link. Please try again.';
          }

          _showErrorSnackBar(errorMessage);
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final currentUser = authService.getCurrentUser();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body:
          _isLoading
              ? ProfileShimmerLoading(isDark: isDark)
              : CustomScrollView(
                slivers: [
                  // Modern App Bar with simple design
                  SliverAppBar(
                    expandedHeight: 160,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor:
                        isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(
                        'My Profile',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.grey.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      background: Container(
                        color:
                            isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                      ),
                    ),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.grey.shade900,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Profile Avatar with gradient border
                            ProfileAvatar(
                              hasProfileImage: _userData?['hasProfileImage'],
                              emojiAvatar: _userData?['emojiAvatar'],
                              isDark: isDark,
                              onEditTap: _showImageSourceDialog,
                            ),

                            const SizedBox(height: 20),

                            // User name or email header
                            Text(
                              _userData?['displayName'] ??
                                  currentUser?.email?.split('@')[0] ??
                                  'User',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Bio
                            if (_userData?['bio'] != null &&
                                _userData!['bio'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                child: Text(
                                  _userData!['bio'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 8),

                            // Status badge
                            ProfileStatusBadge(
                              status: 'Active',
                              color: Colors.green,
                            ),

                            const SizedBox(height: 30),

                            // Stats Cards
                            ProfileStatsSection(stats: _stats, isDark: isDark),

                            const SizedBox(height: 30),

                            // Account Information Section
                            ProfileSectionHeader(
                              title: 'Account Information',
                              isDark: isDark,
                            ),
                            ProfileInfoCard(
                              icon: Icons.email_rounded,
                              title: 'Email Address',
                              subtitle: currentUser?.email ?? 'No email',
                              isDark: isDark,
                              onTap:
                                  () => _copyToClipboard(
                                    context,
                                    currentUser?.email ?? '',
                                    'Email',
                                  ),
                            ),

                            const SizedBox(height: 12),

                            ProfileInfoCard(
                              icon: Icons.fingerprint,
                              title: 'User ID',
                              subtitle: currentUser?.uid ?? 'No ID',
                              isDark: isDark,
                              onTap:
                                  () => _copyToClipboard(
                                    context,
                                    currentUser?.uid ?? '',
                                    'User ID',
                                  ),
                            ),

                            const SizedBox(height: 12),

                            ProfileInfoCard(
                              icon: Icons.shield_outlined,
                              title: 'Account Status',
                              subtitle: 'Verified & Secure',
                              isDark: isDark,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),

                            // Show phone number if available
                            if (_userData?['phoneNumber'] != null &&
                                _userData!['phoneNumber']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ProfileInfoCard(
                                icon: Icons.phone,
                                title: 'Phone Number',
                                subtitle: _userData!['phoneNumber'],
                                isDark: isDark,
                                onTap:
                                    () => _copyToClipboard(
                                      context,
                                      _userData!['phoneNumber'] ?? '',
                                      'Phone Number',
                                    ),
                              ),
                            ],

                            // Show username if available
                            if (_userData?['username'] != null &&
                                _userData!['username']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ProfileInfoCard(
                                icon: Icons.alternate_email,
                                title: 'Username',
                                subtitle: '@${_userData!['username']}',
                                isDark: isDark,
                                onTap:
                                    () => _copyToClipboard(
                                      context,
                                      '@${_userData!['username']}',
                                      'Username',
                                    ),
                              ),
                            ],

                            // Show location if available
                            if (_userData?['location'] != null &&
                                _userData!['location']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ProfileInfoCard(
                                icon: Icons.location_on_outlined,
                                title: 'Location',
                                subtitle: _userData!['location'],
                                isDark: isDark,
                                onTap:
                                    () => _copyToClipboard(
                                      context,
                                      _userData!['location'] ?? '',
                                      'Location',
                                    ),
                              ),
                            ],

                            // Show website if available
                            if (_userData?['website'] != null &&
                                _userData!['website']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ProfileInfoCard(
                                icon: Icons.link,
                                title: 'Website',
                                subtitle: _userData!['website'],
                                isDark: isDark,
                                onTap:
                                    () => _copyToClipboard(
                                      context,
                                      _userData!['website'] ?? '',
                                      'Website',
                                    ),
                              ),
                            ],

                            const SizedBox(height: 30),

                            // Quick Actions Section
                            ProfileSectionHeader(
                              title: 'Quick Actions',
                              isDark: isDark,
                            ),

                            // Edit Profile
                            ProfileActionCard(
                              icon: Icons.edit_outlined,
                              iconColor: Colors.blue,
                              title: 'Edit Profile',
                              subtitle: 'Update your information',
                              isDark: isDark,
                              onTap: _navigateToEditProfile,
                            ),

                            const SizedBox(height: 12),

                            // Change Photo
                            ProfileActionCard(
                              icon: Icons.photo_camera_outlined,
                              iconColor: Colors.purple,
                              title: 'Change Photo',
                              subtitle: 'Update your profile picture',
                              isDark: isDark,
                              onTap: _showImageSourceDialog,
                            ),

                            const SizedBox(height: 12),

                            // Share Profile
                            ProfileActionCard(
                              icon: Icons.share_outlined,
                              iconColor: Colors.green,
                              title: 'Share Profile',
                              subtitle: 'Share your contact info',
                              isDark: isDark,
                              onTap: () {
                                final email = _userData?['email'] ?? '';
                                final displayName =
                                    _userData?['displayName'] ?? 'User';
                                _copyToClipboard(
                                  context,
                                  '$displayName\nEmail: $email',
                                  'Profile info',
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // QR Code
                            ProfileActionCard(
                              icon: Icons.qr_code_2_outlined,
                              iconColor: Colors.orange,
                              title: 'My QR Code',
                              subtitle: 'Show your QR code',
                              isDark: isDark,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'QR Code feature coming soon!',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Privacy Settings
                            ProfileActionCard(
                              icon: Icons.privacy_tip_outlined,
                              iconColor: Colors.teal,
                              title: 'Privacy Settings',
                              subtitle: 'Control who can see your info',
                              isDark: isDark,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Privacy Settings coming soon!',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            // Change Password
                            ProfileActionCard(
                              icon: Icons.lock_reset_outlined,
                              iconColor: Colors.red,
                              title: 'Change Password',
                              subtitle: 'Reset your account password',
                              isDark: isDark,
                              onTap: () => _showChangePasswordDialog(),
                            ),

                            const SizedBox(height: 12),

                            // Notification Settings
                            ProfileActionCard(
                              icon: Icons.notifications_outlined,
                              iconColor: Colors.amber,
                              title: 'Notifications',
                              subtitle: 'Manage notification preferences',
                              isDark: isDark,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notification settings coming soon!',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
