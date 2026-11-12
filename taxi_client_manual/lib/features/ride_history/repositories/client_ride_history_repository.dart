import 'package:firebase_auth/firebase_auth.dart';
import '../services/client_ride_history_service.dart';
import '../../rides/domain/ride_entity.dart';
import '../../rides/domain/location_entity.dart';
import '../domain/repositories/client_ride_history_repository_contract.dart';

class ClientRideHistoryRepository implements ClientRideHistoryRepositoryContract {
  final ClientRideHistoryService _service;
  final FirebaseAuth _auth;

  ClientRideHistoryRepository(this._service, this._auth);

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<List<RideEntity>> getCompletedRides(String filterType) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('يجب تسجيل الدخول');

    DateTime startDate;
    final now = DateTime.now();
    switch (filterType) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    final docsData = await _service.getCompletedRides(
      customerId: uid,
      startDate: startDate,
    );

    return docsData.map((data) {
      final id = data.remove('id') as String;
      final pickup = data['pickupLocation'];
      final dest = data['destinationLocation'];
      return RideEntity(
        rideId: id,
        customerId: data['customerId'] ?? '',
        customerName: data['customerName'] ?? '',
        customerPhone: data['customerPhone'] ?? '',
        driverId: data['driverId'] ?? '',
        driverName: data['driverName'] ?? '',
        driverPhone: data['driverPhone'] ?? '',
        driverCarModel: data['driverCarModel'] ?? '',
        driverCarPlate: data['driverCarPlate'] ?? '',
        pickupLocation: LocationEntity(
          latitude: pickup?.latitude ?? 0,
          longitude: pickup?.longitude ?? 0,
        ),
        pickupAddress: data['pickupAddress'] ?? '',
        destinationLocation: LocationEntity(
          latitude: dest?.latitude ?? 0,
          longitude: dest?.longitude ?? 0,
        ),
        destinationAddress: data['destinationAddress'] ?? '',
        status: data['status'] ?? 'completed',
        fare: (data['fare'] ?? 0.0).toDouble(),
        distanceKm: (data['distanceKm'] ?? 0.0).toDouble(),
        createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }
}
