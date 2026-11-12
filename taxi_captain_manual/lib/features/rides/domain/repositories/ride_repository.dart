import '../../../../core/error/result.dart';
import '../entities/ride_entity.dart';

/// عقد Repository — Domain Layer
/// لا يعرف Firebase — فقط أنواع Dart
abstract class CaptainRideRepository {
  /// مراقبة الرحلات المعلّقة (مع فلتر مسافة اختياري)
  Stream<List<RideEntity>> watchPendingRides({
    double? driverLat,
    double? driverLng,
  });

  /// مراقبة رحلة محددة
  Stream<RideEntity?> watchRide(String rideId);

  /// قبول رحلة
  Future<Result<void>> acceptRide({
    required String rideId,
    required String driverId,
  });

  /// تحديث حالة الرحلة
  Future<Result<void>> updateRideStatus({
    required String rideId,
    required String newStatus,
  });

  /// إكمال الرحلة وحساب العمولة
  Future<Result<void>> completeRide({
    required String rideId,
    required String driverId,
  });
}
