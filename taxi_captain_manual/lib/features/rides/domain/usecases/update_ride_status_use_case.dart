import '../../../../core/error/result.dart';
import '../repositories/ride_repository.dart';

/// حالة استخدام: تحديث حالة الرحلة
class UpdateRideStatusUseCase {
  final CaptainRideRepository _repository;
  UpdateRideStatusUseCase(this._repository);

  Future<Result<void>> call({
    required String rideId,
    required String newStatus,
  }) {
    return _repository.updateRideStatus(rideId: rideId, newStatus: newStatus);
  }
}
