import '../../../rides/domain/entities/ride_entity.dart';

/// عقد Repository — Domain Layer
abstract class RideHistoryRepositoryContract {
  Future<List<RideEntity>> getCompletedRides(String filterType);
}
