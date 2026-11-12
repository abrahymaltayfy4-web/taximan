import '../../../../core/error/result.dart';
import '../repositories/customer_ride_repository.dart';

/// إلغاء رحلة
class CancelRideUseCase {
  final CustomerRideRepository _repository;

  const CancelRideUseCase(this._repository);

  Future<Result<void>> call(String rideId) {
    return _repository.cancelRide(rideId);
  }
}
