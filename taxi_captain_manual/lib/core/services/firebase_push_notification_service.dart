import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/firestore_fields.dart';
import 'notification_service.dart';
import 'push_notification_service.dart';

/// يدير Firebase Cloud Messaging — يخزن الـ token ويعرض إشعارات الـ foreground
class FirebasePushNotificationService implements PushNotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final NotificationService _notifications;

  FirebasePushNotificationService({
    required FirebaseMessaging messaging,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required NotificationService notifications,
  }) : _messaging = messaging,
       _auth = auth,
       _firestore = firestore,
       _notifications = notifications;

  @override
  Future<void> initialize({required String collectionName}) async {
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
      _notifications.show(title: title, body: body);
    });

    // إشعارات الخلفية يعرضها النظام تلقائياً — لا يحتاج كود إضافي
  }

  Future<void> _saveToken(String token, String collectionName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection(collectionName).doc(uid).update({
      FirestoreFields.fcmToken: token,
    });
    debugPrint('FCM token saved for $uid');
  }
}
