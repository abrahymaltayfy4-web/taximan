import '../entities/driver_entity.dart';

/// عقد Repository لبيانات السائق — Domain Layer
abstract class DriverRepositoryContract {
  Future<void> saveDriverData(DriverEntity driver, {bool isRegistration = false});
  Future<DriverEntity?> getDriverData(String uid);
  Future<void> updateDriverStatus(String driverId, String status);
  Future<void> updateLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  });
}
