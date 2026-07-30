// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/firebase_auth_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepository(this._authService);

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _authService.signInWithEmail(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await _authService.registerWithEmail(email: email, password: password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}