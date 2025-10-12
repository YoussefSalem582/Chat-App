import 'package:flutter/material.dart';

class ChatOptionsSheet extends StatelessWidget {
  final bool isUserBlocked;
  final VoidCallback onWallpaperTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onBlockTap;
  final VoidCallback onReportTap;

  const ChatOptionsSheet({
    super.key,
    required this.isUserBlocked,
    required this.onWallpaperTap,
    required this.onNotificationsTap,
    required this.onBlockTap,
    required this.onReportTap,
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
            ListTile(
              leading: const Icon(Icons.wallpaper),
              title: const Text('Wallpaper'),
              subtitle: const Text('Change chat background'),
              onTap: onWallpaperTap,
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              subtitle: const Text('Manage notification settings'),
              onTap: onNotificationsTap,
            ),
            ListTile(
              leading: Icon(
                isUserBlocked ? Icons.check_circle : Icons.block,
                color: isUserBlocked ? Colors.green : null,
              ),
              title: Text(isUserBlocked ? 'Unblock User' : 'Block User'),
              subtitle: Text(
                isUserBlocked
                    ? 'Allow messages from this user'
                    : 'Stop receiving messages',
              ),
              onTap: onBlockTap,
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Report', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Report this user'),
              onTap: onReportTap,
            ),
          ],
        ),
      ),
    );
  }
}
