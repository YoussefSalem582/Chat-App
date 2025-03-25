import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUseremail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUseremail,
      senderEmail: currentUserId,
      receiverID: receiverID,
      receiverEmail: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverID];
    ids.sort(); // sort the ids (this ensures the chatroomID is same for any 2 users)
    String chatRoomID = ids.join("_");

    // add new message to database
    await _firestore
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chat room ID for 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort(); // sort the ids (this ensures the chatroomID is same for any 2 users)
    String chatRoomID = ids.join("_");

    return _firestore
        .collection("ChatRooms")
        .doc(chatRoomID)
        .collection("Messages")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}
