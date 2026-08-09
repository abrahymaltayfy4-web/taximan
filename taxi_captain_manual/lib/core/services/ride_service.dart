import 'package:cloud_firestore/cloud_firestore.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> acceptRide({required String rideId, required String driverId}) async {
    final rideRef = _firestore.collection('rides').doc(rideId);
    final driverRef = _firestore.collection('drivers').doc(driverId);

    await _firestore.runTransaction((transaction) async {
      final rideDoc = await transaction.get(rideRef);
      if (!rideDoc.exists) {
        throw Exception('الرحلة غير موجودة');
      }

      final status = rideDoc.data()?['status'];
      if (status != 'pending') {
        throw Exception('عذراً، هذه الرحلة لم تعد متاحة');
      }

      final distanceKm = (rideDoc.data()?['distanceKm'] ?? 0.0).toDouble();

      final driverDoc = await transaction.get(driverRef);
      if (!driverDoc.exists) {
        throw Exception('بيانات السائق غير موجودة');
      }

      final driverData = driverDoc.data()!;
      final pricePerKm = (driverData['pricePerKm'] ?? 0.0).toDouble();
      final fare = distanceKm * pricePerKm;

      transaction.update(rideRef, {
        'status': 'accepted',
        'driverId': driverId,
        'driverName': driverData['name'],
        'driverPhone': driverData['phone'],
        'driverCarModel': driverData['carModel'],
        'driverCarPlate': driverData['carPlate'],
        'fare': fare,
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(driverRef, {
        'status': 'busy',
      });
    });
  }

  Future<void> updateRideStatus({required String rideId, required String status}) async {
    final data = <String, dynamic>{
      'status': status,
    };
    if (status == 'completed') {
      data['completedAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection('rides').doc(rideId).update(data);
  }

  Future<void> completeRide({required String rideId, required String driverId}) async {
    final rideRef = _firestore.collection('rides').doc(rideId);
    final driverRef = _firestore.collection('drivers').doc(driverId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(rideRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(driverRef, {
        'status': 'online',
      });
    });
  }

  Stream<QuerySnapshot> streamPendingRides() {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<DocumentSnapshot> streamRide(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots();
  }
}