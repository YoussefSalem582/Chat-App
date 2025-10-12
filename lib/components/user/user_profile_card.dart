import 'package:flutter/material.dart';
import 'user_avatar.dart';
import 'online_status_indicator.dart';

class UserProfileCard extends StatelessWidget {
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? imageUrl;
  final bool isOnline;
  final String? bio;
  final List<Widget>? actions;

  const UserProfileCard({
    super.key,
    required this.name,
    this.email,
    this.phoneNumber,
    this.imageUrl,
    this.isOnline = false,
    this.bio,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          UserAvatar(
            name: name,
            imageUrl: imageUrl,
            size: 100,
            showOnlineStatus: true,
            isOnline: isOnline,
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Status
          OnlineStatusText(isOnline: isOnline),

          // Email/Phone
          if (email != null || phoneNumber != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (email != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color:
                              isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          email!,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  if (email != null && phoneNumber != null)
                    const SizedBox(height: 4),
                  if (phoneNumber != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color:
                              isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          phoneNumber!,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDark
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],

          // Bio
          if (bio != null) ...[
            const SizedBox(height: 16),
            Text(
              bio!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Actions
          if (actions != null) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: actions!,
            ),
          ],
        ],
      ),
    );
  }
}
