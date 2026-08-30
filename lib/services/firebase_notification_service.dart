import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _requestPermission();

    await _initLocalNotifications();

    await _listenToForegroundMessages();

    await printFcmToken();
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(initializationSettings);

    const androidChannel = AndroidNotificationChannel(
      'care_pathway_channel',
      'Care Pathway Notifications',
      description: 'Notifications from Care Pathway AI',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _listenToForegroundMessages() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification == null) {
        return;
      }

      _showLocalNotification(
        title: notification.title ?? "Care Pathway AI",
        body: notification.body ?? "",
      );
    });
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'care_pathway_channel',
      'Care Pathway Notifications',
      channelDescription: 'Notifications from Care Pathway AI',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  Future<void> printFcmToken() async {
    final token = await getToken();

    debugPrint("FCM TOKEN: $token");
  }
}
