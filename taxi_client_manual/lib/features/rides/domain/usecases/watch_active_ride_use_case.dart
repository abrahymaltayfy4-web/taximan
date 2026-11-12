import '../../../../core/domain/location_entity.dart';
import '../../../../core/error/result.dart';
import '../entities/ride_entity.dart';
import '../repositories/customer_ride_repository.dart';

/// مراقبة رحلة نشطة + موقع السائق
class WatchActiveRideUseCase {
  final CustomerRideRepository _repository;

  const WatchActiveRideUseCase(this._repository);

  Stream<Result<RideEntity>> call(String rideId) {
    return _repository.watchRide(rideId);
  }

  Stream<Result<LocationEntity>> watchDriverLocation(String driverId) {
    return _repository.watchDriverLocation(driverId);
  }
}
