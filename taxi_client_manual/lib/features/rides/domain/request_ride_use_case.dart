import '../../../core/error/result.dart';
import '../domain/customer_ride_repository.dart';
import '../domain/location_entity.dart';

/// طلب رحلة جديدة
class RequestRideUseCase {
  final CustomerRideRepository _repository;

  const RequestRideUseCase(this._repository);

  Future<Result<String>> call({
    required LocationEntity pickupLocation,
    required String pickupAddress,
    required LocationEntity destinationLocation,
    required String destinationAddress,
    required double distanceKm,
  }) {
    return _repository.requestRide(
      pickupLocation: pickupLocation,
      pickupAddress: pickupAddress,
      destinationLocation: destinationLocation,
      destinationAddress: destinationAddress,
      distanceKm: distanceKm,
    );
  }
}
