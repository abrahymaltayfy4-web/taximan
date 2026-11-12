import '../../../rides/domain/ride_entity.dart';

/// عقد Repository — Domain Layer
abstract class ClientRideHistoryRepositoryContract {
  Future<List<RideEntity>> getCompletedRides(String filterType);
}
