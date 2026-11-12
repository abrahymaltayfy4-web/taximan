import 'package:firebase_auth/firebase_auth.dart';

/// مصدر المصادقة — عقد مستقل عن Firebase (يعيد uid فقط)
abstract interface class ClientAuthRemoteDataSource {
  Future<String> signInWithEmail({
    required String email,
    required String password,
  });

  Future<String> registerWithEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();
}

class FirebaseClientAuthRemoteDataSource implements ClientAuthRemoteDataSource {
  final FirebaseAuth _auth;

  const FirebaseClientAuthRemoteDataSource(this._auth);

  @override
  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
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
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
