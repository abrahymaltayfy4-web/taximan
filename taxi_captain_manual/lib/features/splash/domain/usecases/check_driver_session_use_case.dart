/// Domain — Splash Use Case
/// يتحقق من حالة المصادقة بعد انتظار مدة الـ splash
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SplashResult {
  /// مصادق عليه ونشط
  authenticated,
  /// محظور
  blocked,
  /// قيد المراجعة
  pendingApproval,
  /// مرفوض
  rejected,
  /// غير مسجل دخول أو حساب عميل
  unauthenticated,
}

class CheckDriverSessionUseCase {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CheckDriverSessionUseCase(this._auth, this._firestore);

  /// ينتظر [minDelay] ثم يفحص الجلسة
  Future<SplashResult> call({
    Duration minDelay = const Duration(seconds: 2),
  }) async {
    // ننتظر الحد الأدنى لعرض الـ splash
    await Future.delayed(minDelay);

    final user = _auth.currentUser;
    if (user == null) return SplashResult.unauthenticated;

    // التحقق من وجود وثيقة الكابتن
    final driverDoc =
        await _firestore.collection('drivers').doc(user.uid).get();

    if (!driverDoc.exists) {
      // حساب عميل — نسجل خروج
      await _auth.signOut();
      return SplashResult.unauthenticated;
    }

    final data = driverDoc.data();

    // التحقق من الحظر
    if (data?['isBlocked'] == true) {
      await _auth.signOut();
      return SplashResult.blocked;
    }

    // التحقق من حالة الموافقة
    final approvalStatus = data?['approvalStatus'] ?? 'approved';
    if (approvalStatus == 'pending') {
      await _auth.signOut();
      return SplashResult.pendingApproval;
    }
    if (approvalStatus == 'rejected') {
      await _auth.signOut();
      return SplashResult.rejected;
    }

    return SplashResult.authenticated;
  }
}
