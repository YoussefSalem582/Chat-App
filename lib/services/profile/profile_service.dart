import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUserId == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection("Users").doc(currentUserId).get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Upload profile image (Temporary Firestore solution - stores base64)
  // Note: This is not recommended for production. Upgrade to Firebase Blaze plan for proper Storage.
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      if (currentUserId == null) {
        print('Error: User not logged in');
        return null;
      }

      print('Starting upload for user: $currentUserId');
      print('Image file path: ${imageFile.path}');

      // Verify file exists
      if (!await imageFile.exists()) {
        print('Error: Image file does not exist');
        return null;
      }

      // Check file size (limit to 1MB for Firestore)
      final fileSize = await imageFile.length();
      print('Image file size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      if (fileSize > 1024 * 1024) {
        print('Error: Image too large. Please compress the image.');
        return null;
      }

      print('Converting image to base64...');

      // Read image as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert to base64
      final base64Image = base64Encode(bytes);

      print('Base64 conversion complete. Length: ${base64Image.length}');
      print('Uploading to Firestore...');

      // Store in Firestore as base64
      final imageData = {
        'base64': base64Image,
        'contentType': 'image/jpeg',
        'uploadedAt': FieldValue.serverTimestamp(),
        'userId': currentUserId,
      };

      // Save to a subcollection for better organization
      await _firestore
          .collection("Users")
          .doc(currentUserId)
          .collection("profile_images")
          .doc('current')
          .set(imageData);

      // Update user document with flag that image exists
      await _firestore.collection("Users").doc(currentUserId).update({
        'hasProfileImage': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Image uploaded successfully to Firestore');

      // Return a special marker indicating base64 storage
      return 'firestore_base64';
    } catch (e, stackTrace) {
      print('Error uploading profile image: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Get profile image from Firestore
  Future<Uint8List?> getProfileImage() async {
    try {
      if (currentUserId == null) return null;

      DocumentSnapshot doc =
          await _firestore
              .collection("Users")
              .doc(currentUserId)
              .collection("profile_images")
              .doc('current')
              .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String base64Image = data['base64'];
        return base64Decode(base64Image);
      }
      return null;
    } catch (e) {
      print('Error getting profile image: $e');
      return null;
    }
  }

  // Get profile image for any user (for display in chat list, etc.)
  Future<Uint8List?> getUserProfileImage(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection("Users")
              .doc(userId)
              .collection("profile_images")
              .doc('current')
              .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String base64Image = data['base64'];
        return base64Decode(base64Image);
      }
      return null;
    } catch (e) {
      print('Error getting user profile image: $e');
      return null;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  // Update user display name
  Future<bool> updateDisplayName(String displayName) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection("Users").doc(currentUserId).update({
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating display name: $e');
      return false;
    }
  }

  // Update user bio
  Future<bool> updateBio(String bio) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection("Users").doc(currentUserId).update({
        'bio': bio,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating bio: $e');
      return false;
    }
  }

  // Update user phone number
  Future<bool> updatePhoneNumber(String phoneNumber) async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection("Users").doc(currentUserId).update({
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating phone number: $e');
      return false;
    }
  }

  // Get user statistics
  Future<Map<String, int>> getUserStats() async {
    try {
      if (currentUserId == null) {
        return {'messages': 0, 'contacts': 0, 'groups': 0};
      }

      // Count messages sent by user
      QuerySnapshot messagesSnapshot =
          await _firestore
              .collection("chat_rooms")
              .where('participants', arrayContains: currentUserId)
              .get();

      int totalMessages = 0;
      for (var chatRoom in messagesSnapshot.docs) {
        QuerySnapshot msgs =
            await _firestore
                .collection("chat_rooms")
                .doc(chatRoom.id)
                .collection("messages")
                .where('senderID', isEqualTo: currentUserId)
                .get();
        totalMessages += msgs.docs.length;
      }

      // Count contacts (unique chat participants)
      Set<String> contacts = {};
      for (var chatRoom in messagesSnapshot.docs) {
        List<dynamic> participants = chatRoom.get('participants') ?? [];
        for (var participant in participants) {
          if (participant != currentUserId) {
            contacts.add(participant);
          }
        }
      }

      return {
        'messages': totalMessages,
        'contacts': contacts.length,
        'groups': 0, // Placeholder for future group feature
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {'messages': 0, 'contacts': 0, 'groups': 0};
    }
  }

  // Delete profile image
  Future<bool> deleteProfileImage() async {
    try {
      if (currentUserId == null) return false;

      // Delete from Firestore subcollection
      await _firestore
          .collection("Users")
          .doc(currentUserId)
          .collection("profile_images")
          .doc('current')
          .delete();

      // Update user document
      await _firestore.collection("Users").doc(currentUserId).update({
        'hasProfileImage': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error deleting profile image: $e');
      return false;
    }
  }

  // Set emoji avatar
  Future<bool> setEmojiAvatar(String emoji) async {
    try {
      if (currentUserId == null) {
        print('Cannot set emoji: currentUserId is null');
        return false;
      }

      print('Setting emoji avatar: $emoji for user: $currentUserId');

      // Update user document with emoji
      await _firestore.collection("Users").doc(currentUserId).update({
        'emojiAvatar': emoji,
        'hasProfileImage': false, // Clear image if emoji is set
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Emoji avatar saved to Firestore successfully');

      // Delete any existing profile image
      try {
        await _firestore
            .collection("Users")
            .doc(currentUserId)
            .collection("profile_images")
            .doc('current')
            .delete();
      } catch (e) {
        // Ignore if no image exists
      }

      return true;
    } catch (e) {
      print('Error setting emoji avatar: $e');
      return false;
    }
  }

  // Remove emoji avatar
  Future<bool> removeEmojiAvatar() async {
    try {
      if (currentUserId == null) return false;

      await _firestore.collection("Users").doc(currentUserId).update({
        'emojiAvatar': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error removing emoji avatar: $e');
      return false;
    }
  }

  // Get random emoji for avatar
  static String getRandomEmoji() {
    final emojis = [
      '😀',
      '😃',
      '😄',
      '😁',
      '😆',
      '😅',
      '🤣',
      '😂',
      '🙂',
      '🙃',
      '😉',
      '😊',
      '😇',
      '🥰',
      '😍',
      '🤩',
      '😎',
      '🤓',
      '🧐',
      '🥳',
      '😺',
      '😸',
      '😹',
      '😻',
      '🤖',
      '👽',
      '👾',
      '🦄',
      '🐶',
      '🐱',
      '🐭',
      '🐹',
      '🐰',
      '🦊',
      '🐻',
      '🐼',
      '🐨',
      '🐯',
      '🦁',
      '🐮',
      '🐷',
      '🐸',
      '🐵',
      '🐔',
      '🐧',
      '🐦',
      '🦆',
      '🦉',
    ];
    emojis.shuffle();
    return emojis.first;
  }
}
