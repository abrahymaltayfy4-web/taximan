import '../core/services/ride_service.dart';
import '../models/ride_model.dart';
import 'dart:math' as math;

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

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 - math.cos((lat2 - lat1) * p) / 2 + math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  Stream<List<RideModel>> streamPendingRides({double? driverLat, double? driverLng}) {
    return _rideService.streamPendingRides().map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs.map((doc) {
        return RideModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).where((ride) {
        if (ride.createdAt.isBefore(now.subtract(const Duration(minutes: 3)))) return false;
        if (driverLat != null && driverLng != null) {
          final distance = _calculateDistance(
            driverLat, driverLng, 
            ride.pickupLocation.latitude, ride.pickupLocation.longitude
          );
          if (distance > 2.0) return false;
        }
        return true;
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