import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/notification/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // get user stream
  /*
  List<Map<String, dynamic> =

  [
  {
  'email': youssef@gmail.com,
  'id': ..
  },
  {
  'email': test@gmail.com,
  'id': ..
  },
  ]

  */
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        // return the user
        return user;
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(
    String receiverID,
    message, {
    String? messageType,
  }) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      receiverEmail: receiverID,
      message: message,
      timestamp: timestamp,
      messageType: messageType ?? 'text',
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids (this ensures the chatroomID is same for any 2 users)
    String chatRoomID = ids.join("_");

    // add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Send push notification to receiver
    try {
      await _notificationService.sendNotificationToUser(
        receiverId: receiverID,
        senderName: currentUserEmail,
        message: message,
      );
    } catch (e) {
      // Notification failure shouldn't stop message sending
      print('Failed to send notification: $e');
    }
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chat room ID for 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort(); // sort the ids (this ensures the chatroomID is same for any 2 users)
    String chatRoomID = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // delete message (soft delete - mark as deleted instead of removing)
  Future<void> deleteMessage(String chatRoomID, String messageID) async {
    try {
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .doc(messageID)
          .update({'message': 'DELETED MESSAGE', 'isDeleted': true});
    } catch (e) {
      throw "Failed to delete message: ${e.toString()}";
    }
  }

  // get chat room ID for two users
  String getChatRoomID(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    return ids.join("_");
  }

  // get last message for a chat
  Stream<QuerySnapshot> getLastMessage(String userID, String otherUserID) {
    String chatRoomID = getChatRoomID(userID, otherUserID);
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots();
  }

  // set typing status
  Future<void> setTypingStatus(String receiverID, bool isTyping) async {
    String currentUserID = _auth.currentUser!.uid;
    String chatRoomID = getChatRoomID(currentUserID, receiverID);

    try {
      await _firestore.collection("chat_rooms").doc(chatRoomID).set({
        'typing_$currentUserID': isTyping,
        'lastActivity': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail - typing indicator is not critical
    }
  }

  // get typing status
  Stream<DocumentSnapshot> getTypingStatus(String userID, String otherUserID) {
    String chatRoomID = getChatRoomID(userID, otherUserID);
    return _firestore.collection("chat_rooms").doc(chatRoomID).snapshots();
  }

  // add reaction to message
  Future<void> addReaction(
    String chatRoomID,
    String messageID,
    String reaction,
  ) async {
    String currentUserID = _auth.currentUser!.uid;

    try {
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .doc(messageID)
          .set({
            'reactions': {currentUserID: reaction},
          }, SetOptions(merge: true));
    } catch (e) {
      throw "Failed to add reaction: ${e.toString()}";
    }
  }

  // remove reaction from message
  Future<void> removeReaction(String chatRoomID, String messageID) async {
    String currentUserID = _auth.currentUser!.uid;

    try {
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .doc(messageID)
          .update({'reactions.$currentUserID': FieldValue.delete()});
    } catch (e) {
      throw "Failed to remove reaction: ${e.toString()}";
    }
  }

  // Reply to a message
  Future<void> sendReplyMessage(
    String receiverID,
    String message,
    String replyToMessageId,
    String replyToMessage,
  ) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add({
          'senderID': currentUserID,
          'senderEmail': currentUserEmail,
          'receiverID': receiverID,
          'message': message,
          'timestamp': timestamp,
          'replyTo': {'messageId': replyToMessageId, 'message': replyToMessage},
        });

    // Send notification
    try {
      await _notificationService.sendNotificationToUser(
        receiverId: receiverID,
        senderName: currentUserEmail,
        message: message,
      );
    } catch (e) {
      print('Failed to send notification: $e');
    }
  }

  // Get user online status
  Stream<DocumentSnapshot> getUserStatus(String userId) {
    return _firestore.collection("Users").doc(userId).snapshots();
  }

  // Update user online status
  Future<void> updateUserStatus(bool isOnline) async {
    String currentUserID = _auth.currentUser!.uid;
    try {
      await _firestore.collection("Users").doc(currentUserID).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to update status: $e');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatRoomID, String userId) async {
    try {
      final messages =
          await _firestore
              .collection("chat_rooms")
              .doc(chatRoomID)
              .collection("messages")
              .where('receiverID', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

      for (var doc in messages.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  // Search messages
  Future<List<Map<String, dynamic>>> searchMessages(
    String chatRoomID,
    String query,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection("chat_rooms")
              .doc(chatRoomID)
              .collection("messages")
              .orderBy("timestamp", descending: true)
              .get();

      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final message = data['message']?.toString().toLowerCase() ?? '';
            return message.contains(query.toLowerCase()) &&
                (data['isDeleted'] ?? false) == false;
          })
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw "Failed to search messages: ${e.toString()}";
    }
  }
}
