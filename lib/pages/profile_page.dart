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

                            const SizedBox(height: 30),

                            // Quick Actions Section
                            ProfileSectionHeader(
                              title: 'Quick Actions',
                              isDark: isDark,
                            ),
                            ProfileActionCard(
                              icon: Icons.edit,
                              iconColor: Colors.blue,
                              title: 'Edit Profile',
                              subtitle: 'Update your information',
                              isDark: isDark,
                              onTap: _navigateToEditProfile,
                            ),

                            const SizedBox(height: 12),

                            ProfileActionCard(
                              icon: Icons.lock_outline,
                              iconColor: Colors.orange,
                              title: 'Change Password',
                              subtitle: 'Update your security',
                              isDark: isDark,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Change Password coming soon!',
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 12),

                            ProfileActionCard(
                              icon: Icons.privacy_tip_outlined,
                              iconColor: Colors.purple,
                              title: 'Privacy Settings',
                              subtitle: 'Control your privacy',
                              isDark: isDark,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Privacy Settings coming soon!',
                                    ),
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
