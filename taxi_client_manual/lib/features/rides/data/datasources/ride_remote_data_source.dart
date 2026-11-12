import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/constants/firestore_fields.dart';
import '../../../../core/domain/location_entity.dart';
import '../../../../core/domain/ride_status.dart';
import '../../domain/entities/ride_entity.dart';
import '../mappers/ride_mapper.dart';
import '../models/ride_model.dart';

/// مصدر بيانات الرحلات (العميل) — عقد مستقل عن Firebase
abstract interface class RideRemoteDataSource {
  Future<String> createRide(NewRideRequest request);

  Stream<RideModel?> watchRide(String rideId);

  Stream<LocationEntity?> watchDriverLocation(String driverId);

  Future<void> cancelRide(String rideId);

  Future<List<RideModel>> getCompletedRides({
    required String customerId,
    required DateTime since,
  });
}

class FirebaseRideRemoteDataSource implements RideRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FirebaseRideRemoteDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _rides =>
      _firestore.collection(FirestoreCollections.rides);

  @override
  Future<String> createRide(NewRideRequest r) async {
    final docRef = await _rides.add({
      'customerId': r.customerId,
      'customerName': r.customerName,
      'customerPhone': r.customerPhone,
      'driverId': null,
      'driverName': null,
      'driverPhone': null,
      'driverCarModel': null,
      'driverCarPlate': null,
      'pickupLocation': RideMapper.toGeoPoint(r.pickupLocation),
      'pickupAddress': r.pickupAddress,
      'destinationLocation': RideMapper.toGeoPoint(r.destinationLocation),
      'destinationAddress': r.destinationAddress,
      FirestoreFields.status: RideStatus.pending.value,
      'fare': r.fare,
      'distanceKm': r.distanceKm,
      FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      'acceptedAt': null,
      'completedAt': null,
    });
    return docRef.id;
  }

  @override
  Stream<RideModel?> watchRide(String rideId) {
    return _rides.doc(rideId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return RideModel(snapshot.id, data);
    });
  }

  @override
  Stream<LocationEntity?> watchDriverLocation(String driverId) {
    return _firestore
        .collection(FirestoreCollections.drivers)
        .doc(driverId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return null;
          return RideMapper.driverLocation(snapshot.data());
        });
  }

  @override
  Future<void> cancelRide(String rideId) {
    return _rides.doc(rideId).update({
      FirestoreFields.status: RideStatus.cancelled.value,
    });
  }

  @override
  Future<List<RideModel>> getCompletedRides({
    required String customerId,
    required DateTime since,
  }) async {
    final snapshot = await _rides
        .where(FirestoreFields.customerId, isEqualTo: customerId)
        .where(FirestoreFields.status, isEqualTo: RideStatus.completed.value)
        .where(
          FirestoreFields.createdAt,
          isGreaterThanOrEqualTo: Timestamp.fromDate(since),
        )
        .orderBy(FirestoreFields.createdAt, descending: true)
        .get();
    return snapshot.docs.map((d) => RideModel(d.id, d.data())).toList();
  }
}
