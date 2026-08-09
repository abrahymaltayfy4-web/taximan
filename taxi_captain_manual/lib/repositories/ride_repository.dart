import '../core/services/ride_service.dart';
import '../models/ride_model.dart';

class RideRepository {
  final RideService _rideService;

  RideRepository(this._rideService);

  Future<void> acceptRide({required String rideId, required String driverId}) async {
    await _rideService.acceptRide(rideId: rideId, driverId: driverId);
  }

  Future<void> updateRideStatus({required String rideId, required String status}) async {
    await _rideService.updateRideStatus(rideId: rideId, status: status);
  }

  Future<void> completeRide({required String rideId, required String driverId}) async {
    await _rideService.completeRide(rideId: rideId, driverId: driverId);
  }

  Stream<List<RideModel>> streamPendingRides() {
    return _rideService.streamPendingRides().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RideModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Stream<RideModel?> streamRide(String rideId) {
    return _rideService.streamRide(rideId).map((doc) {
      if (doc.exists && doc.data() != null) {
        return RideModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }
}