import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

/// يدير Firebase Cloud Messaging — يخزن الـ token ويعرض الإشعارات
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// يُستدعى مرة واحدة عند بدء التطبيق
  /// [collectionName] = 'drivers' أو 'clients'
  static Future<void> initialize({required String collectionName}) async {
    // طلب إذن الإشعارات
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');

    // جلب الـ token وحفظه
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveToken(token, collectionName);
    }

    // عند تحديث الـ token
    _messaging.onTokenRefresh.listen((newToken) {
      _saveToken(newToken, collectionName);
    });

    // إشعارات تصل والتطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'إشعار';
      final body = message.notification?.body ?? '';
      NotificationService.showNotification(title: title, body: body);
    });

    // إشعارات تصل والتطبيق في الخلفية — يعرضها النظام تلقائياً
    // لا يحتاج كود إضافي
  }

  static Future<void> _saveToken(String token, String collectionName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(uid)
        .update({'fcmToken': token});
    debugPrint('FCM token saved for $uid');
  }
}
