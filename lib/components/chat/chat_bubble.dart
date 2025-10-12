import 'package:chat_app/components/chat/message_reaction_picker.dart';
import 'package:chat_app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final Timestamp timestamp;
  final VoidCallback? onDelete;
  final bool isDeleted;
  final String messageId;
  final String chatRoomId;
  final Map<String, dynamic>? reactions;
  final Function(String)? onReactionTap;

  ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    this.onDelete,
    this.isDeleted = false,
    required this.messageId,
    required this.chatRoomId,
    this.reactions,
    this.onReactionTap,
  });

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time in 12-hour format with AM/PM
      int hour = dateTime.hour;
      String period = hour >= 12 ? 'PM' : 'AM';

      // Convert to 12-hour format
      if (hour > 12) {
        hour = hour - 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // light vs dark mode for correct bubble color
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return GestureDetector(
      onLongPress: () {
        _showMessageOptions(context);
      },
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color:
                  isCurrentUser
                      ? (isDarkMode
                          ? Colors.green.shade600
                          : Colors.green.shade500)
                      : (isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color:
                        isCurrentUser
                            ? Colors.white
                            : (isDarkMode ? Colors.white : Colors.black),
                    fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                    fontSize: isDeleted ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    color:
                        isCurrentUser
                            ? Colors.white70
                            : (isDarkMode ? Colors.white70 : Colors.black54),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          // Display reactions
          if (reactions != null && reactions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 35.0, right: 35.0, top: 2.0),
              child: Wrap(
                spacing: 4,
                children:
                    reactions!.entries.map((entry) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    // Don't show options for deleted messages
    if (isDeleted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Reaction picker
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: MessageReactionPicker(
                    onReactionSelected: (reaction) {
                      Navigator.pop(context);
                      if (onReactionTap != null) {
                        onReactionTap!(reaction);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reacted with $reaction'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Message'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: message));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (isCurrentUser && onDelete != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Message',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onDelete != null) {
                    onDelete!();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
