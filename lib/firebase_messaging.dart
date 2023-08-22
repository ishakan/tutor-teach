import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future initialize() async {
    // Request permission for handling notifications
    await _firebaseMessaging.requestPermission();

    // Configure Firebase messaging settings
    FirebaseMessaging.onMessage.listen(_onMessageReceived);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessageReceived);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Retrieve the device token for sending push notifications
    String? deviceToken = await _firebaseMessaging.getToken();
    print('Device Token: $deviceToken');
  }

  // Handle incoming messages when the app is in the foreground
  void _onMessageReceived(RemoteMessage message) {
    print('Received message: ${message.notification?.title}');
  }

  // Handle background messages when the app is in the background or terminated
  Future<void> _onBackgroundMessageReceived(RemoteMessage message) async {
    print('Received background message: ${message.notification?.title}');
  }

  // Handle messages opened from the notification tray when the app is in the background or terminated
  void _onMessageOpenedApp(RemoteMessage message) {
    print('Opened app from message: ${message.notification?.title}');
  }


  void sendNotification(String recipientToken, String title, String body) async {
    // Firebase Cloud Messaging server key (replace with your actual server key)
    final serverKey = 'AAAAbe7FRrU:APA91bEjD-M6m3SUXfQUmu9FApb_aWaEKQv-gUrn6iR7H70FcYAzm8xfbdY3Yanat5vrKmGyE-Bj9Dr7aHjti_gU9EoWsnN2z-f7i5sxKE_8AhfiZp__hpyA1dcY4WeUUQArtywakaGt';

    // FCM API endpoint
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    // Notification payload
    final payload = {
      'to': recipientToken,
      'notification': {
        'title': title,
        'body': body,
        'sound': 'default',
      },
    };

    // Send the notification request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Error: ${response.body}');
    }
  }
}
