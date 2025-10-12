/**
 * Firebase Cloud Function for Chat App Push Notifications
 * 
 * This function sends push notifications when new messages are created in Firestore.
 * Deploy this function to enable real-time notifications in your chat app.
 * 
 * Setup:
 * 1. Install Firebase CLI: npm install -g firebase-tools
 * 2. Initialize functions: firebase init functions
 * 3. Copy this code to functions/index.js
 * 4. Install dependencies: cd functions && npm install
 * 5. Deploy: firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
admin.initializeApp();

/**
 * Send notification when a new message is created
 * Triggers on: chat_rooms/{chatRoomId}/messages/{messageId}
 */
exports.sendMessageNotification = functions.firestore
  .document('chat_rooms/{chatRoomId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const message = snap.data();
      const chatRoomId = context.params.chatRoomId;
      const messageId = context.params.messageId;

      console.log(`New message ${messageId} in chat room ${chatRoomId}`);

      // Don't send notification if message is deleted
      if (message.isDeleted) {
        console.log('Message is deleted, skipping notification');
        return null;
      }

      // Get receiver information
      const receiverId = message.receiverID;
      const senderEmail = message.senderEmail || 'Someone';
      const messageText = message.message || 'New message';

      console.log(`Fetching receiver data for: ${receiverId}`);

      // Get receiver's user document
      const receiverDoc = await admin.firestore()
        .collection('Users')
        .doc(receiverId)
        .get();

      if (!receiverDoc.exists) {
        console.log('Receiver user not found');
        return null;
      }

      const receiverData = receiverDoc.data();
      const fcmToken = receiverData.fcmToken;

      if (!fcmToken) {
        console.log('Receiver does not have FCM token');
        return null;
      }

      // Check notification settings
      const settings = receiverData.notificationSettings || {};
      if (settings.enabled === false) {
        console.log('Notifications disabled for this user');
        return null;
      }

      // Prepare notification payload
      const payload = {
        notification: {
          title: senderEmail,
          body: messageText.length > 100 
            ? messageText.substring(0, 97) + '...' 
            : messageText,
          sound: settings.sound !== false ? 'default' : '',
        },
        data: {
          senderId: message.senderID,
          senderEmail: senderEmail,
          chatRoomId: chatRoomId,
          messageId: messageId,
          type: 'chat_message',
          timestamp: message.timestamp.toMillis().toString(),
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'chat_messages',
            sound: settings.sound !== false ? 'default' : '',
            tag: chatRoomId, // Group notifications by chat
            color: '#4CAF50', // Green color for notifications
          },
        },
        apns: {
          payload: {
            aps: {
              badge: 1,
              sound: settings.sound !== false ? 'default' : '',
              alert: {
                title: senderEmail,
                body: messageText,
              },
            },
          },
        },
      };

      console.log('Sending notification to token:', fcmToken.substring(0, 20) + '...');

      // Send notification
      const response = await admin.messaging().sendToDevice(fcmToken, payload);

      console.log('Successfully sent notification:', response);

      // Check for errors
      if (response.failureCount > 0) {
        const errors = response.results
          .map((result, index) => result.error ? index : null)
          .filter(index => index !== null);
        
        console.error('Failed to send to some devices:', errors);
        
        // If token is invalid, remove it from Firestore
        if (response.results[0].error?.code === 'messaging/invalid-registration-token' ||
            response.results[0].error?.code === 'messaging/registration-token-not-registered') {
          console.log('Removing invalid FCM token');
          await admin.firestore()
            .collection('Users')
            .doc(receiverId)
            .update({
              fcmToken: admin.firestore.FieldValue.delete(),
            });
        }
      }

      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  });

/**
 * Clean up FCM tokens when user logs out
 * Optional: Triggers on user document update
 */
exports.cleanupFCMToken = functions.firestore
  .document('Users/{userId}')
  .onUpdate((change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // If FCM token was deleted, log it
    if (before.fcmToken && !after.fcmToken) {
      console.log(`FCM token removed for user: ${context.params.userId}`);
    }

    return null;
  });

/**
 * Send welcome notification when user registers
 * Optional feature
 */
exports.sendWelcomeNotification = functions.firestore
  .document('Users/{userId}')
  .onCreate(async (snap, context) => {
    try {
      const userData = snap.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.log('No FCM token for new user');
        return null;
      }

      const payload = {
        notification: {
          title: '👋 Welcome to Chat App!',
          body: 'Start connecting with friends and family.',
          sound: 'default',
        },
        data: {
          type: 'welcome',
        },
      };

      await admin.messaging().sendToDevice(fcmToken, payload);
      console.log('Welcome notification sent to:', userData.email);

      return null;
    } catch (error) {
      console.error('Error sending welcome notification:', error);
      return null;
    }
  });

/**
 * Send notification to multiple users (broadcast)
 * Call this from client app or another function
 */
exports.sendBroadcastNotification = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to send broadcast.'
    );
  }

  try {
    const { title, body, topic } = data;

    if (!title || !body) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Title and body are required.'
      );
    }

    const message = {
      notification: { title, body },
      data: { type: 'broadcast' },
    };

    let response;
    if (topic) {
      // Send to topic (all subscribers)
      message.topic = topic;
      response = await admin.messaging().send(message);
    } else {
      // Send to all users
      const usersSnapshot = await admin.firestore().collection('Users').get();
      const tokens = [];

      usersSnapshot.forEach(doc => {
        const fcmToken = doc.data().fcmToken;
        if (fcmToken) tokens.push(fcmToken);
      });

      if (tokens.length > 0) {
        response = await admin.messaging().sendMulticast({
          tokens,
          notification: message.notification,
          data: message.data,
        });
      }
    }

    console.log('Broadcast sent:', response);
    return { success: true, response };
  } catch (error) {
    console.error('Error sending broadcast:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Scheduled function to clean up old messages
 * Runs every day at midnight
 */
exports.cleanupOldMessages = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const chatRoomsSnapshot = await admin.firestore()
        .collection('chat_rooms')
        .get();

      let deletedCount = 0;

      for (const chatRoom of chatRoomsSnapshot.docs) {
        const messagesSnapshot = await chatRoom.ref
          .collection('messages')
          .where('timestamp', '<', admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
          .get();

        const batch = admin.firestore().batch();
        
        messagesSnapshot.forEach(doc => {
          batch.delete(doc.ref);
          deletedCount++;
        });

        await batch.commit();
      }

      console.log(`Deleted ${deletedCount} old messages`);
      return null;
    } catch (error) {
      console.error('Error cleaning up messages:', error);
      return null;
    }
  });
