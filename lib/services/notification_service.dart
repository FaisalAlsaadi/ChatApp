import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin
  _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize the notification service
  Future<void> initialize(BuildContext context) async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging
        .requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

    // Configure local notifications
    final AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    final InitializationSettings initSettings =
        InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        );

    // Initialize with the new callback pattern for newer versions of the plugin
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (
        NotificationResponse response,
      ) {
        final String? payload = response.payload;
        if (payload != null) {
          _handlePayload(payload, context);
        }
      },
    );

    // Subscribe to Firebase FCM topic for the current user
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firebaseMessaging.subscribeToTopic(
        currentUser.uid,
      );

      // Save the FCM token to Firestore
      await _saveTokenToFirestore();
    }

    // Handle incoming messages when app is in foreground
    FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      _showNotification(message);
    });

    // Handle notification clicks when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) {
      _handleNotificationClick(message, context);
    });
  }

  // Handle notification payload
  void _handlePayload(
    String payload,
    BuildContext context,
  ) {
    final payloadData = payload.split(',');
    if (payloadData.length >= 2) {
      final receiverID = payloadData[0];
      final receiverEmail = payloadData[1];
      // Navigate to chat page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatPage(
                receiverEmail: receiverEmail,
                receiverID: receiverID,
              ),
        ),
      );
    }
  }

  // Save FCM token to Firestore
  Future<void> _saveTokenToFirestore() async {
    String? token = await _firebaseMessaging.getToken();
    final currentUser = _auth.currentUser;

    if (token != null && currentUser != null) {
      await _firestore
          .collection('Users')
          .doc(currentUser.uid)
          .update({'fcmToken': token});
    }
  }

  // Show local notification
  Future<void> _showNotification(
    RemoteMessage message,
  ) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android =
        message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'New Message',
        notification.body ?? 'You have a new message',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'chat_messages',
            'Chat Messages',
            channelDescription:
                'Notifications for new chat messages',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload:
            '${message.data['senderID'] ?? ''},${message.data['senderEmail'] ?? ''}',
      );
    }
  }

  // Handle notification click
  void _handleNotificationClick(
    RemoteMessage message,
    BuildContext context,
  ) {
    if (message.data.containsKey('senderID') &&
        message.data.containsKey('senderEmail')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatPage(
                receiverID: message.data['senderID'],
                receiverEmail: message.data['senderEmail'],
              ),
        ),
      );
    }
  }

  // Send notification when a new message is sent
  Future<void> sendMessageNotification({
    required String receiverID,
    required String message,
    required String senderEmail,
  }) async {
    // Get the receiver's FCM token
    final receiverData =
        await _firestore
            .collection('Users')
            .doc(receiverID)
            .get();

    final receiverToken = receiverData.data()?['fcmToken'];

    if (receiverToken != null) {}
  }

  // Update FCM token when it refreshes
  void setupTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((
      token,
    ) {
      _saveTokenToFirestore();
    });
  }
}
