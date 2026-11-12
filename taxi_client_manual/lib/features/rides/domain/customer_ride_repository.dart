import '../../../core/error/result.dart';
import 'ride_entity.dart';
import 'location_entity.dart';

/// واجهة Repository للرحلات — Domain Layer
/// لا تعتمد على أي تقنية خارجية
abstract class CustomerRideRepository {
  /// طلب رحلة جديدة — يعيد ride ID
  Future<Result<String>> requestRide({
    required LocationEntity pickupLocation,
    required String pickupAddress,
    required LocationEntity destinationLocation,
    required String destinationAddress,
    required double distanceKm,
  });

  /// مراقبة حالة رحلة نشطة
  Stream<Result<RideEntity>> watchActiveRide(String rideId);

  /// مراقبة موقع السائق
  Stream<Result<LocationEntity>> watchDriverLocation(String driverId);

  /// إلغاء رحلة
  Future<Result<void>> cancelRide(String rideId);

  /// جلب سجل الرحلات
  Future<Result<List<RideEntity>>> loadRideHistory();
}
