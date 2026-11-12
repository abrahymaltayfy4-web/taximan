import '../../../../core/error/result.dart';
import '../../../rides/domain/repositories/customer_ride_repository.dart';
import '../entities/ride_history.dart';

class LoadRideHistoryUseCase {
  final CustomerRideRepository _repository;
  final DateTime Function() _now;

  LoadRideHistoryUseCase(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  Future<Result<RideHistory>> call(RideHistoryFilter filter) async {
    final result = await _repository.getCompletedRides(
      since: filter.startDate(_now()),
    );
    switch (result) {
      case Success(data: final rides):
        return Result.success(RideHistory.fromRides(rides));
      case Err(failure: final f):
        return Result.failure(f);
    }
  }
}
