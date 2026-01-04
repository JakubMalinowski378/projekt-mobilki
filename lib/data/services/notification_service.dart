import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      final initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );
      
      debugPrint('Notifications initialized: $initialized');

      // Request permissions for Android 13+
      final platform = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (platform != null) {
        final granted = await platform.requestNotificationsPermission();
        debugPrint('Android notifications permission: $granted');
      }
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> showTransactionNotification({
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'transaction_channel',
        'Transactions',
        channelDescription: 'Notifications for new transactions',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
      debugPrint('Notification shown: $title - $body');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
}
