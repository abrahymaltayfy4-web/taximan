import '../../../../core/domain/account_status.dart';

/// بيانات الجلسة المحققة
class SessionInfo {
  final String uid;
  final String name;
  final AccountStatus accountStatus;

  const SessionInfo({
    required this.uid,
    required this.name,
    required this.accountStatus,
  });
}

/// واجهة إدارة الجلسة — Domain Layer
abstract class SessionRepository {
  /// هل يوجد مستخدم مسجل حالياً؟
  bool get hasCurrentUser;

  /// فحص الجلسة: يعيد SessionInfo أو null
  Future<SessionInfo?> checkSession();

  /// تسجيل خروج
  Future<void> signOut();

  /// بدء خدمات الإشعارات (FCM + Admin listener)
  void startNotificationServices();

  /// إيقاف خدمات الإشعارات
  void stopNotificationServices();
}
