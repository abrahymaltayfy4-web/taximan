import '../../../../core/error/result.dart';
import '../repositories/ride_repository.dart';

/// حالة استخدام: قبول رحلة
class AcceptRideUseCase {
  final CaptainRideRepository _repository;
  AcceptRideUseCase(this._repository);

  Future<Result<void>> call({
    required String rideId,
    required String driverId,
  }) {
    return _repository.acceptRide(rideId: rideId, driverId: driverId);
  }
}
