import '../../../rides/domain/entities/ride_entity.dart';
import '../repositories/ride_history_repository_contract.dart';

class LoadRideHistoryUseCase {
  final RideHistoryRepositoryContract _repository;
  LoadRideHistoryUseCase(this._repository);

  Future<List<RideEntity>> call(String filterType) {
    return _repository.getCompletedRides(filterType);
  }
}
