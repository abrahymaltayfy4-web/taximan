import 'package:firebase_auth/firebase_auth.dart';
import '../core/infrastructure/firebase_auth_service.dart';
import '../features/driver_auth/domain/repositories/auth_repository_contract.dart';

/// تنفيذ AuthRepository — Data Layer
class AuthRepository implements AuthRepositoryContract {
  final FirebaseAuthService _authService;

  AuthRepository(this._authService);

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  @override
  Future<String> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.registerWithEmail(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }
}
