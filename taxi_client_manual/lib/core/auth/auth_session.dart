/// الجلسة الحالية — abstraction فوق FirebaseAuth حتى لا يعرف أي repository/cubit
/// شيئاً عن Firebase. التنفيذ في [FirebaseAuthSession].
abstract interface class AuthSession {
  /// معرّف المستخدم الحالي أو null إن لم يكن مسجل دخول
  String? get currentUserId;

  /// اسم احتياطي للمستخدم من حساب المصادقة (displayName ثم email)
  String? get fallbackDisplayName;

  /// تسجيل الخروج
  Future<void> signOut();
}
