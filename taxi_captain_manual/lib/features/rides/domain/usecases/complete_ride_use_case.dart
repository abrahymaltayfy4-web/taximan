import '../../../../core/error/result.dart';
import '../repositories/ride_repository.dart';

/// حالة استخدام: إكمال الرحلة
class CompleteRideUseCase {
  final CaptainRideRepository _repository;
  CompleteRideUseCase(this._repository);

  Future<Result<void>> call({
    required String rideId,
    required String driverId,
  }) {
    return _repository.completeRide(rideId: rideId, driverId: driverId);
  }
}
