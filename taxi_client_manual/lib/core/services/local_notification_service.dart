import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

/// تنفيذ [NotificationService] عبر flutter_local_notifications
class LocalNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final String _channelDescription;
  bool _initialized = false;

  /// [channelDescription] يختلف بين التطبيقين (طلبات جديدة للكابتن / حالة الرحلة للعميل)
  LocalNotificationService(
    this._plugin, {
    required String channelDescription,
  }) : _channelDescription = channelDescription;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    _initialized = true;

    // طلب إذن الإشعارات (Android 13+)
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  @override
  Future<void> show({required String title, required String body}) async {
    final androidDetails = AndroidNotificationDetails(
      'ride_channel',
      'إشعارات الرحلات',
      channelDescription: _channelDescription,
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
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }
}
