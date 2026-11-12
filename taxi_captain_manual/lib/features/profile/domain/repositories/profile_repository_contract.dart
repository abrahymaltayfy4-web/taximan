import '../entities/driver_profile_entity.dart';

/// عقد Repository — Domain Layer
abstract class ProfileRepositoryContract {
  Future<DriverProfileEntity?> getProfile();
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? carModel,
    String? carPlate,
    double? pricePerKm,
  });
}
