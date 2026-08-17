import 'package:firebase_auth/firebase_auth.dart';
import '../services/customer_profile_service.dart';

class CustomerProfileRepository {
  final CustomerProfileService _service;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CustomerProfileRepository(this._service);

  String? get currentUserId => _auth.currentUser?.uid;

  Future<Map<String, dynamic>?> getProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    return await _service.getClientProfile(uid);
  }

  Future<void> updateProfile({required String name, required String phone}) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('يجب تسجيل الدخول');
    await _service.updateClientProfile(uid, {'name': name, 'phone': phone});
  }
}
