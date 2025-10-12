import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/profile/profile_service.dart';

class ProfileAvatar extends StatefulWidget {
  final bool? hasProfileImage;
  final String? emojiAvatar;
  final bool isDark;
  final VoidCallback onEditTap;
  final String? userId; // Optional - for viewing other users' profiles

  const ProfileAvatar({
    super.key,
    this.hasProfileImage,
    this.emojiAvatar,
    required this.isDark,
    required this.onEditTap,
    this.userId,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final ProfileService _profileService = ProfileService();
  Uint8List? _imageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.hasProfileImage == true) {
      _loadImage();
    }
  }

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasProfileImage != oldWidget.hasProfileImage ||
        widget.emojiAvatar != oldWidget.emojiAvatar) {
      if (widget.hasProfileImage == true) {
        _loadImage();
      } else {
        setState(() => _imageBytes = null);
      }
    }
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);

    try {
      final bytes =
          widget.userId != null
              ? await _profileService.getUserProfileImage(widget.userId!)
              : await _profileService.getProfileImage();

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Profile Image or Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  widget.isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              width: 3,
            ),
            color: widget.isDark ? Colors.grey.shade800 : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : widget.emojiAvatar != null
                    ? Center(
                      child: Text(
                        widget.emojiAvatar!,
                        style: const TextStyle(fontSize: 60),
                      ),
                    )
                    : Icon(
                      Icons.person,
                      size: 50,
                      color:
                          widget.isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                    ),
          ),
        ),
        // Edit button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: widget.onEditTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
