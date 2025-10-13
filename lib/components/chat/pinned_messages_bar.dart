import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PinnedMessagesBar extends StatelessWidget {
  final List<QueryDocumentSnapshot> pinnedMessages;
  final VoidCallback onTap;
  final bool isDarkMode;

  const PinnedMessagesBar({
    super.key,
    required this.pinnedMessages,
    required this.onTap,
    this.isDarkMode = false,
  });

  String _formatMessage(String message, {int maxLength = 50}) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    if (pinnedMessages.isEmpty) return const SizedBox.shrink();

    final firstPinned = pinnedMessages.first.data() as Map<String, dynamic>;
    final message = firstPinned['message'] ?? '';
    final isDeleted = firstPinned['isDeleted'] ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.amber.shade900.withOpacity(0.3)
                  : Colors.amber.shade100,
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.amber.shade800 : Colors.amber.shade300,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.push_pin,
              size: 20,
              color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade800,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pinnedMessages.length == 1
                        ? 'Pinned Message'
                        : '${pinnedMessages.length} Pinned Messages',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isDarkMode
                              ? Colors.amber.shade300
                              : Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDeleted ? 'DELETED MESSAGE' : _formatMessage(message),
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle:
                          isDeleted ? FontStyle.italic : FontStyle.normal,
                      color:
                          isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }
}
