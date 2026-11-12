import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/firestore_collections.dart';
import 'admin_notification_listener.dart';
import 'notification_service.dart';

class FirestoreAdminNotificationListener implements AdminNotificationListener {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NotificationService _notifications;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _isInitialLoad = true;

  FirestoreAdminNotificationListener({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required NotificationService notifications,
  }) : _firestore = firestore,
       _auth = auth,
       _notifications = notifications;

  @override
  void startListening({
    required String targetAll,
    required String targetSpecific,
  }) {
    _subscription?.cancel();

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isInitialLoad = true;

    _subscription = _firestore
        .collection(FirestoreCollections.notifications)
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

            final isForMe =
                target == targetAll ||
                (target == targetSpecific && targetId == uid);

            if (isForMe) {
              _notifications.show(
                title: data['title'] ?? 'إشعار',
                body: data['body'] ?? '',
              );
            }
          }
        });
  }

  @override
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }
}
