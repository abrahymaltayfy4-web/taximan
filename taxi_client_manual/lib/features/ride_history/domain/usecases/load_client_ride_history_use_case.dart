import '../../../rides/domain/ride_entity.dart';
import '../repositories/client_ride_history_repository_contract.dart';

class LoadClientRideHistoryUseCase {
  final ClientRideHistoryRepositoryContract _repository;
  LoadClientRideHistoryUseCase(this._repository);

  Future<List<RideEntity>> call(String filterType) =>
      _repository.getCompletedRides(filterType);
}
