// lib/features/client_auth/repositories/client_auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تسجيل حساب عميل جديد
  Future<User?> signUpWithEmailAndPassword({
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
        // حفظ بيانات العميل في مجموعة clients داخل Firestore
        await _firestore.collection('clients').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // تسجيل دخول العميل
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // التحقق من أن الحساب عميل وليس كابتن
        final clientDoc = await _firestore.collection('clients').doc(user.uid).get();
        if (!clientDoc.exists) {
          // هذا حساب كابتن وليس عميل — نرفض الدخول
          await _auth.signOut();
          throw Exception('هذا الحساب مسجل ككابتن. يرجى استخدام تطبيق الكابتن');
        }
      }

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }


  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }
}