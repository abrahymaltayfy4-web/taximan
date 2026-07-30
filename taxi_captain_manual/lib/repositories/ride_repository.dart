// lib/repositories/ride_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';

class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new ride request
  Future<void> createRide(RideModel ride) async {
    await _firestore.collection('rides').doc(ride.rideId).set(ride.toJson());
  }

  // Update ride status (e.g., accepted, started, completed)
  Future<void> updateRideStatus({
    required String rideId,
    required String status,
    String? driverId,
  }) async {
    final Map<String, dynamic> updateData = {'status': status};
    if (driverId != null) {
      updateData['driverId'] = driverId;
    }
    await _firestore.collection('rides').doc(rideId).update(updateData);
  }
}