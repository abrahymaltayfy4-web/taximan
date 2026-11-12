import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/shared/account_status.dart';

/// مصدر بيانات الجلسة من Firebase — Data Layer فقط
class FirebaseSessionDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseSessionDataSource(this._auth, this._firestore);

  /// المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// جلب بيانات العميل من Firestore
  Future<Map<String, dynamic>?> getClientData(String uid) async {
    final doc = await _firestore.collection('clients').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// استخراج AccountStatus من بيانات العميل (يدعم legacy + الجديد)
  AccountStatus extractAccountStatus(Map<String, dynamic>? data) {
    if (data == null) return AccountStatus.active;
    if (data['accountStatus'] != null) {
      return AccountStatus.fromString(data['accountStatus']);
    }
    if (data['isBlocked'] == true) return AccountStatus.blocked;
    return AccountStatus.active;
  }

  /// تسجيل خروج
  Future<void> signOut() => _auth.signOut();
}
