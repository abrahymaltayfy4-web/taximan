/// عقد Auth Repository — Domain Layer
/// لا يعرف Firebase أو أي framework
abstract class AuthRepositoryContract {
  /// تسجيل دخول بالبريد
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  /// تسجيل حساب جديد — يعيد UID
  Future<String> registerWithEmail({
    required String email,
    required String password,
  });

  /// تسجيل خروج
  Future<void> signOut();
}
