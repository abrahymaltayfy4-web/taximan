import '../../../../core/domain/location_entity.dart';
import '../../../../core/error/result.dart';
import '../entities/ride_entity.dart';

/// واجهة Repository للرحلات من جهة العميل — Domain Layer
/// لا تعتمد على أي تقنية خارجية
abstract interface class CustomerRideRepository {
  /// إنشاء رحلة بحالة pending — يعيد ride ID
  Future<Result<String>> createRide(NewRideRequest request);

  /// مراقبة حالة رحلة (Failure إن حُذفت)
  Stream<Result<RideEntity>> watchRide(String rideId);

  /// مراقبة موقع السائق (Failure إن لم يتوفر)
  Stream<Result<LocationEntity>> watchDriverLocation(String driverId);

  /// إلغاء رحلة
  Future<Result<void>> cancelRide(String rideId);

  /// رحلات العميل المكتملة منذ [since]
  Future<Result<List<RideEntity>>> getCompletedRides({required DateTime since});
}
