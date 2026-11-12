/// Push notifications (FCM) — abstraction. التنفيذ في [FirebasePushNotificationService].
abstract interface class PushNotificationService {
  /// يُستدعى بعد نجاح تسجيل الدخول.
  /// [collectionName] مجموعة المستخدم التي يُحفظ فيها الـ token.
  Future<void> initialize({required String collectionName});
}
