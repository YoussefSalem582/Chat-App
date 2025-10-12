import 'package:flutter/material.dart';

class ImageSourceBottomSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onEmojiTap;
  final VoidCallback? onRemoveTap;

  const ImageSourceBottomSheet({
    super.key,
    required this.isDark,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onEmojiTap,
    this.onRemoveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('😀', style: TextStyle(fontSize: 20)),
              ),
              title: const Text('Choose Emoji Avatar'),
              subtitle: const Text('Pick from 100+ emojis'),
              onTap: onEmojiTap,
            ),
            Divider(
              height: 1,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery'),
              onTap: onGalleryTap,
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Take a Photo'),
              onTap: onCameraTap,
            ),
            if (onRemoveTap != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: onRemoveTap,
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required bool isDark,
    required VoidCallback onGalleryTap,
    required VoidCallback onCameraTap,
    required VoidCallback onEmojiTap,
    VoidCallback? onRemoveTap,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ImageSourceBottomSheet(
            isDark: isDark,
            onGalleryTap: onGalleryTap,
            onCameraTap: onCameraTap,
            onEmojiTap: onEmojiTap,
            onRemoveTap: onRemoveTap,
          ),
    );
  }
}
