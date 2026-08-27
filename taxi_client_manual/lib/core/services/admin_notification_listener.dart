import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';

/// يستمع لإشعارات الأدمن من Firestore ويعرضها محلياً
class AdminNotificationListener {
  static StreamSubscription? _subscription;
  static bool _isInitialLoad = true;

  /// بدء الاستماع — يُستدعى مرة واحدة عند فتح التطبيق
  /// [targetAll] = 'all_drivers' لتطبيق الكابتن أو 'all_users' لتطبيق العميل
  /// [targetSpecific] = 'specific_driver' أو 'specific_user'
  static void startListening({
    required String targetAll,
    required String targetSpecific,
  }) {
    _subscription?.cancel();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isInitialLoad = true;

    _subscription = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('sentAt', descending: true)
        .limit(5)
        .snapshots()
        .listen((snapshot) {
      // تجاهل أول snapshot (بيانات قديمة)
      if (_isInitialLoad) {
        _isInitialLoad = false;
        return;
      }

      for (final change in snapshot.docChanges) {
        // فقط الإشعارات الجديدة
        if (change.type != DocumentChangeType.added) continue;

        final data = change.doc.data();
        if (data == null) continue;

        final target = data['target'] as String? ?? '';
        final targetId = data['targetId'] as String? ?? '';

        // تحقق: هل الإشعار موجه لي؟
        bool isForMe = false;
        if (target == targetAll) {
          isForMe = true;
        } else if (target == targetSpecific && targetId == uid) {
          isForMe = true;
        }

        if (isForMe) {
          NotificationService.showNotification(
            title: data['title'] ?? 'إشعار',
            body: data['body'] ?? '',
          );
        }
      }
    });
  }

  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
