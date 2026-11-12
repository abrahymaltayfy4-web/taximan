import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../../../models/driver_model.dart';
import '../domain/entities/driver_profile_entity.dart';
import '../domain/repositories/profile_repository_contract.dart';

/// تنفيذ ProfileRepository — Data Layer
class ProfileRepository implements ProfileRepositoryContract {
  final ProfileService _service;
  final FirebaseAuth _auth;

  ProfileRepository(this._service, this._auth);

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<DriverProfileEntity?> getProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final data = await _service.getDriverProfile(uid);
    if (data == null) return null;
    final model = DriverModel.fromJson(data, uid);
    return DriverProfileEntity(
      uid: model.uid,
      name: model.name,
      phone: model.phone,
      email: model.email,
      carModel: model.carModel,
      carPlate: model.carPlate,
      pricePerKm: model.pricePerKm,
      status: model.status,
      totalCommissionOwed: (data['totalCommissionOwed'] ?? 0.0).toDouble(),
      totalPaid: (data['totalPaid'] ?? 0.0).toDouble(),
    );
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? carModel,
    String? carPlate,
    double? pricePerKm,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (carModel != null) updates['carModel'] = carModel;
    if (carPlate != null) updates['carPlate'] = carPlate;
    if (pricePerKm != null) updates['pricePerKm'] = pricePerKm;
    await _service.updateDriverProfile(uid, updates);
  }
}
