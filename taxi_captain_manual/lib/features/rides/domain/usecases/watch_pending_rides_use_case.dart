import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

/// حالة استخدام: مراقبة الرحلات المعلّقة
class WatchPendingRidesUseCase {
  final CaptainRideRepository _repository;
  WatchPendingRidesUseCase(this._repository);

  Stream<List<RideEntity>> call({double? driverLat, double? driverLng}) {
    return _repository.watchPendingRides(
      driverLat: driverLat,
      driverLng: driverLng,
    );
  }
}
