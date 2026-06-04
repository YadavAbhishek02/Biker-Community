import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:biker_community/core/api/api_client.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<void> initialize() async {
    // 1. Request Permission
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('User granted permission');
      } else {
        log('User declined or has not accepted permission');
      }
    } catch (e) {
      log('Permission request error: $e');
    }

    // 2. Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: \${message.data}');
      if (message.notification != null) {
        log('Notification: \${message.notification?.title}');
      }
    });

    // 4. Handle notification clicks when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification clicked!');
      // Handle navigation here if needed
    });

    // 5. Get and upload token (non-critical — don't let it freeze the app)
    uploadToken(); // intentionally NOT awaited here
  }

  Future<void> uploadToken() async {
    try {
      String? token = await _fcm.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('FCM getToken timed out');
          return null;
        },
      );
      if (token != null) {
        log('FCM Token: $token');
        await _apiClient.dio
            .post('/users/update-fcm-token', data: {'fcmToken': token})
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                log('FCM token upload timed out — skipping');
                return Response(
                  requestOptions: RequestOptions(path: '/users/update-fcm-token'),
                );
              },
            );
      }
    } catch (e) {
      log('Error getting/uploading FCM token: $e');
    }
  }
}

// Global background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message: ${message.messageId}");
}
