import 'package:flutter/material.dart';

enum MessageStatus { pending, sent, delivered, read, failed }

class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final double size;

  const MessageStatusIndicator({
    super.key,
    required this.status,
    this.size = 14,
  });

  // Convert string status to enum
  static MessageStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return MessageStatus.pending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.pending:
        icon = Icons.access_time;
        color = Colors.grey.shade400;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey.shade300;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey.shade300;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.lightGreenAccent;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: size, color: color);
  }
}
