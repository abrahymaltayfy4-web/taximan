/// عقد Auth Repository — Domain Layer
abstract class ClientAuthRepositoryContract {
  Future<String?> signIn({required String email, required String password});
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  Future<void> signOut();
}
