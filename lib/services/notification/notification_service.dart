import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  print('Handling background message: ${message.messageId}');
}

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Firebase Messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Local Notifications instance
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Firestore and Auth instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Notification settings
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Getters for settings
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  /// Initialize the notification service
  Future<void> initialize() async {
    // Request permission for notifications
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Set up Firebase Messaging
    await _setupFirebaseMessaging();

    // Get and save FCM token
    await _saveFCMToken();

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined or has not accepted notification permission');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize with settings
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Set up Firebase Messaging handlers
  Future<void> _setupFirebaseMessaging() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Get and save FCM token to Firestore
  Future<void> _saveFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          await _firestore.collection('Users').doc(currentUser.uid).set({
            'fcmToken': token,
            'platform': Platform.operatingSystem,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('FCM Token saved: $token');
        }
      }
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Handle token refresh
  Future<void> _onTokenRefresh(String token) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('Users').doc(currentUser.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('FCM Token refreshed: $token');
      }
    } catch (e) {
      print('Error refreshing FCM token: $e');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');

    if (!_notificationsEnabled) return;

    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'New Message',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Android notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_messages', // channel ID
      'Chat Messages', // channel name
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: _vibrationEnabled,
      playSound: _soundEnabled,
      icon: '@mipmap/ic_launcher',
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Combined notification details
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show notification
    await _localNotifications.show(
      DateTime.now().millisecond, // notification ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');
    // TODO: Navigate to chat page with the sender
    // You can access message data via message.data
    if (message.data.containsKey('senderId')) {
      String senderId = message.data['senderId'];
      print('Navigate to chat with user: $senderId');
      // Navigation will be handled in main.dart
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Send notification to specific user
  Future<void> sendNotificationToUser({
    required String receiverId,
    required String senderName,
    required String message,
  }) async {
    try {
      // Get receiver's FCM token
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(receiverId).get();

      if (!userDoc.exists) {
        print('User document not found');
        return;
      }

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      String? fcmToken = userData?['fcmToken'];

      if (fcmToken == null) {
        print('FCM token not found for user');
        return;
      }

      // In a production app, you would call your backend API here
      // to send the notification using Firebase Admin SDK
      print('Would send notification to token: $fcmToken');
      print('From: $senderName, Message: $message');

      // Note: You need a backend server to actually send the notification
      // This is because client SDKs cannot send FCM messages directly
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  /// Update notification settings
  Future<void> updateSettings({
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) async {
    if (enabled != null) _notificationsEnabled = enabled;
    if (sound != null) _soundEnabled = sound;
    if (vibration != null) _vibrationEnabled = vibration;

    // Save settings to Firestore
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('Users').doc(currentUser.uid).set({
          'notificationSettings': {
            'enabled': _notificationsEnabled,
            'sound': _soundEnabled,
            'vibration': _vibrationEnabled,
          },
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  /// Load notification settings from Firestore
  Future<void> loadSettings() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          Map<String, dynamic>? settings =
              userData?['notificationSettings'] as Map<String, dynamic>?;

          if (settings != null) {
            _notificationsEnabled = settings['enabled'] ?? true;
            _soundEnabled = settings['sound'] ?? true;
            _vibrationEnabled = settings['vibration'] ?? true;
          }
        }
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  /// Delete FCM token (call on logout)
  Future<void> deleteFCMToken() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('Users').doc(currentUser.uid).update({
          'fcmToken': FieldValue.delete(),
        });
        await _firebaseMessaging.deleteToken();
        print('FCM Token deleted');
      }
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }

  /// Subscribe to topic (for broadcast messages)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}
