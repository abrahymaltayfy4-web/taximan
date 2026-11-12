import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

/// حالة استخدام: مراقبة رحلة نشطة
class WatchActiveRideUseCase {
  final CaptainRideRepository _repository;
  WatchActiveRideUseCase(this._repository);

  Stream<RideEntity?> call(String rideId) {
    return _repository.watchRide(rideId);
  }
}
