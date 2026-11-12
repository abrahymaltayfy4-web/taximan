/// هوية التطبيق (عميل) — تُستخدم لتحديد مجموعة المستخدمين وأهداف إشعارات الأدمن
/// بدل نشر magic strings داخل الـ cubits/الـ repositories.
abstract final class AppRole {
  /// مجموعة Firestore التي يُحفظ فيها المستخدم و FCM token
  static const String userCollection = 'clients';

  /// هدف إشعارات الأدمن الموجهة لكل المستخدمين
  static const String notificationTargetAll = 'all_users';

  /// هدف إشعارات الأدمن الموجهة لمستخدم محدد
  static const String notificationTargetSpecific = 'specific_user';
}
