import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;

    // طلب إذن الإشعارات (Android 13+)
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  static Future<void> showNotification({required String title, required String body}) async {
    final androidDetails = AndroidNotificationDetails(
      'ride_channel',
      'إشعارات الرحلات',
      channelDescription: 'إشعارات حالة الرحلة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      // إشعارات تظهر كبانر أعلى الشاشة مثل الواتساب
      fullScreenIntent: true,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(body),
    );
    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(DateTime.now().millisecondsSinceEpoch % 100000, title, body, details);
  }
}
