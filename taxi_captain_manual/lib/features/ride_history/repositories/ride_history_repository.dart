import 'package:firebase_auth/firebase_auth.dart';
import '../services/ride_history_service.dart';
import '../../../models/ride_model.dart';
import '../../rides/domain/entities/ride_entity.dart';
import '../../rides/domain/entities/location_entity.dart';
import '../domain/repositories/ride_history_repository_contract.dart';

/// تنفيذ RideHistoryRepository — Data Layer
class RideHistoryRepository implements RideHistoryRepositoryContract {
  final RideHistoryService _service;
  final FirebaseAuth _auth;

  RideHistoryRepository(this._service, this._auth);

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<List<RideEntity>> getCompletedRides(String filterType) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    final now = DateTime.now();
    DateTime startDate;

    if (filterType == 'اليوم') {
      startDate = DateTime(now.year, now.month, now.day);
    } else if (filterType == 'الأسبوع') {
      startDate = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 7));
    } else if (filterType == 'الشهر') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, now.month, now.day);
    }

    final docsData = await _service.getCompletedRides(
      driverId: uid,
      startDate: startDate,
    );

    return docsData.map((data) {
      final id = data.remove('id') as String;
      final model = RideModel.fromJson(data, id);
      return RideEntity(
        rideId: model.rideId,
        customerId: model.customerId,
        customerName: model.customerName,
        customerPhone: model.customerPhone,
        driverId: model.driverId,
        driverName: model.driverName,
        driverPhone: model.driverPhone,
        driverCarModel: model.driverCarModel,
        driverCarPlate: model.driverCarPlate,
        pickupLocation: LocationEntity(
          latitude: model.pickupLocation.latitude,
          longitude: model.pickupLocation.longitude,
        ),
        pickupAddress: model.pickupAddress,
        destinationLocation: LocationEntity(
          latitude: model.destinationLocation.latitude,
          longitude: model.destinationLocation.longitude,
        ),
        destinationAddress: model.destinationAddress,
        status: model.status,
        fare: model.fare,
        distanceKm: model.distanceKm,
        createdAt: model.createdAt,
        acceptedAt: model.acceptedAt,
        completedAt: model.completedAt,
      );
    }).toList();
  }
}
