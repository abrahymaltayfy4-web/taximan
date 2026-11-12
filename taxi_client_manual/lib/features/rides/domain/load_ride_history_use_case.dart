import '../../../core/error/result.dart';
import '../domain/customer_ride_repository.dart';
import '../domain/ride_entity.dart';

/// جلب سجل الرحلات
class LoadRideHistoryUseCase {
  final CustomerRideRepository _repository;

  const LoadRideHistoryUseCase(this._repository);

  Future<Result<List<RideEntity>>> call() {
    return _repository.loadRideHistory();
  }
}
