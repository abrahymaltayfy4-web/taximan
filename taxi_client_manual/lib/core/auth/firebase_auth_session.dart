import 'package:firebase_auth/firebase_auth.dart';
import 'auth_session.dart';

class FirebaseAuthSession implements AuthSession {
  final FirebaseAuth _auth;

  const FirebaseAuthSession(this._auth);

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  String? get fallbackDisplayName {
    final user = _auth.currentUser;
    return user?.displayName ?? user?.email;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
