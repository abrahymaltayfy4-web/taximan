import 'package:firebase_auth/firebase_auth.dart';
import '../services/profile_service.dart';
import '../../../models/driver_model.dart';

class ProfileRepository {
  final ProfileService _service;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileRepository(this._service);

  String? get currentUserId => _auth.currentUser?.uid;

  Future<DriverModel?> getProfile() async {
    final uid = currentUserId;
    if (uid == null) return null;
    final data = await _service.getDriverProfile(uid);
    if (data == null) return null;
    return DriverModel.fromJson(data, uid);
  }

  Future<void> updateProfile({String? name, String? phone, String? carModel, String? carPlate, double? pricePerKm}) async {
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
