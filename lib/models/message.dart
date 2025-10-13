import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String receiverEmail;
  final String message;
  final Timestamp timestamp;
  final String? messageType; // 'text', 'image', 'document', 'location'
  final bool isRead; // Track if message has been read
  final bool isDeleted; // Track if message is deleted
  final bool isPinned; // Track if message is pinned
  final Map<String, dynamic>? reactions; // User reactions {userId: emoji}
  final String? replyToMessageId; // ID of message being replied to
  final String? replyToMessage; // Content of message being replied to
  final String status; // 'pending', 'sent', 'delivered', 'read'
  final String? linkPreviewUrl; // URL for link preview
  final Map<String, dynamic>? linkPreviewData; // Link preview metadata

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.receiverEmail,
    required this.message,
    required this.timestamp,
    this.messageType,
    this.isRead = false, // Default to unread
    this.isDeleted = false,
    this.isPinned = false,
    this.reactions,
    this.replyToMessageId,
    this.replyToMessage,
    this.status = 'sent',
    this.linkPreviewUrl,
    this.linkPreviewData,
  });

  // convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'receiverEmail': receiverEmail,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType ?? 'text',
      'isRead': isRead,
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'reactions': reactions ?? {},
      'replyToMessageId': replyToMessageId,
      'replyToMessage': replyToMessage,
      'status': status,
      'linkPreviewUrl': linkPreviewUrl,
      'linkPreviewData': linkPreviewData,
    };
  }

  // Create from Firestore document
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      receiverID: map['receiverID'] ?? '',
      receiverEmail: map['receiverEmail'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      messageType: map['messageType'],
      isRead: map['isRead'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      isPinned: map['isPinned'] ?? false,
      reactions:
          map['reactions'] != null
              ? Map<String, dynamic>.from(map['reactions'])
              : null,
      replyToMessageId: map['replyToMessageId'],
      replyToMessage: map['replyToMessage'],
      status: map['status'] ?? 'sent',
      linkPreviewUrl: map['linkPreviewUrl'],
      linkPreviewData:
          map['linkPreviewData'] != null
              ? Map<String, dynamic>.from(map['linkPreviewData'])
              : null,
    );
  }
}
