import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/repositories/client_auth_repository_contract.dart';

class ClientAuthRepository implements ClientAuthRepositoryContract {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ClientAuthRepository(this._auth, this._firestore);

  @override
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      if (user != null) {
        await _firestore.collection('clients').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user?.uid;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<String?> signIn({required String email, required String password}) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final clientDoc = await _firestore.collection('clients').doc(user.uid).get();
        if (!clientDoc.exists) {
          await _auth.signOut();
          throw Exception('هذا الحساب مسجل ككابتن. يرجى استخدام تطبيق الكابتن');
        }
      }
      return user?.uid;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
