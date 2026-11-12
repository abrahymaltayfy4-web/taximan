import 'dart:math' as math;
import '../../../../core/error/result.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/infrastructure/ride_service.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';
import '../mappers/ride_mapper.dart';
import '../models/ride_model.dart';

/// تنفيذ CaptainRideRepository — Data Layer
/// يستخدم RideService (Firebase) ويحوّل البيانات عبر RideMapper
class CaptainRideRepositoryImpl implements CaptainRideRepository {
  final RideService _rideService;

  CaptainRideRepositoryImpl(this._rideService);

  @override
  Stream<List<RideEntity>> watchPendingRides({
    double? driverLat,
    double? driverLng,
  }) {
    return _rideService.streamPendingRides().map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs
          .map((doc) {
            final model = RideModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            return RideMapper.toEntity(model);
          })
          .where((ride) {
            // فلتر الرحلات القديمة (> 3 دقائق)
            if (ride.createdAt.isBefore(
              now.subtract(const Duration(minutes: 3)),
            )) {
              return false;
            }
            // فلتر المسافة (2 كم)
            if (driverLat != null && driverLng != null) {
              final distance = _calculateDistance(
                driverLat,
                driverLng,
                ride.pickupLocation.latitude,
                ride.pickupLocation.longitude,
              );
              if (distance > 2.0) return false;
            }
            return true;
          })
          .toList();
    });
  }

  @override
  Stream<RideEntity?> watchRide(String rideId) {
    return _rideService.streamRide(rideId).map((doc) {
      if (doc.exists && doc.data() != null) {
        return RideMapper.fromFirestore(doc);
      }
      return null;
    });
  }

  @override
  Future<Result<void>> acceptRide({
    required String rideId,
    required String driverId,
  }) {
    return safeCall(() async {
      await _rideService.acceptRide(rideId: rideId, driverId: driverId);
    });
  }

  @override
  Future<Result<void>> updateRideStatus({
    required String rideId,
    required String newStatus,
  }) {
    return safeCall(() async {
      await _rideService.updateRideStatus(rideId: rideId, status: newStatus);
    });
  }

  @override
  Future<Result<void>> completeRide({
    required String rideId,
    required String driverId,
  }) {
    return safeCall(() async {
      await _rideService.completeRide(rideId: rideId, driverId: driverId);
    });
  }

  /// Haversine formula لحساب المسافة بين نقطتين بالكيلومتر
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295;
    final a =
        0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }
}
