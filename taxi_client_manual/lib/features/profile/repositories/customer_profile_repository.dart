import 'package:firebase_auth/firebase_auth.dart';
import '../services/customer_profile_service.dart';
import '../domain/entities/customer_profile_entity.dart';
import '../domain/repositories/customer_profile_repository_contract.dart';

class CustomerProfileRepository implements CustomerProfileRepositoryContract {
  final CustomerProfileService _service;
  final FirebaseAuth _auth;

  CustomerProfileRepository(this._service, this._auth);

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<CustomerProfileEntity?> getProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final data = await _service.getClientProfile(uid);
    if (data == null) return null;
    return CustomerProfileEntity(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('يجب تسجيل الدخول');
    await _service.updateClientProfile(uid, {'name': name, 'phone': phone});
  }
}
