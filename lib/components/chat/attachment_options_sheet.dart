import 'package:flutter/material.dart';

class AttachmentOptionsSheet extends StatelessWidget {
  final VoidCallback onImageTap;
  final VoidCallback onCameraTap;
  final VoidCallback onDocumentTap;
  final VoidCallback onLocationTap;

  const AttachmentOptionsSheet({
    super.key,
    required this.onImageTap,
    required this.onCameraTap,
    required this.onDocumentTap,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Send Attachment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const Divider(),
            _buildAttachmentOption(
              icon: Icons.image,
              iconColor: Colors.purple,
              backgroundColor: Colors.purple.shade100,
              title: 'Image',
              subtitle: 'Send photos from gallery',
              onTap: onImageTap,
            ),
            _buildAttachmentOption(
              icon: Icons.camera_alt,
              iconColor: Colors.blue,
              backgroundColor: Colors.blue.shade100,
              title: 'Camera',
              subtitle: 'Take a photo',
              onTap: onCameraTap,
            ),
            _buildAttachmentOption(
              icon: Icons.insert_drive_file,
              iconColor: Colors.orange,
              backgroundColor: Colors.orange.shade100,
              title: 'Document',
              subtitle: 'Send files',
              onTap: onDocumentTap,
            ),
            _buildAttachmentOption(
              icon: Icons.location_on,
              iconColor: Colors.green,
              backgroundColor: Colors.green.shade100,
              title: 'Location',
              subtitle: 'Share your location',
              onTap: onLocationTap,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
