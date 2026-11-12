import '../../../core/error/result.dart';
import '../domain/customer_ride_repository.dart';
import '../domain/ride_entity.dart';
import '../domain/location_entity.dart';

/// مراقبة رحلة نشطة + موقع السائق
class WatchActiveRideUseCase {
  final CustomerRideRepository _repository;

  const WatchActiveRideUseCase(this._repository);

  Stream<Result<RideEntity>> call(String rideId) {
    return _repository.watchActiveRide(rideId);
  }

  Stream<Result<LocationEntity>> watchDriverLocation(String driverId) {
    return _repository.watchDriverLocation(driverId);
  }
}
