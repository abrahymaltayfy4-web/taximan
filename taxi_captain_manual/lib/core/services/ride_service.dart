import 'package:cloud_firestore/cloud_firestore.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // دالة قبول الرحلة ترجع Future<void> فقط ولا تتعامل مع الواجهة أو الـ Context
  Future<void> acceptRide({
    required String rideId,
    required String driverId,
  }) async {
    await _firestore.runTransaction((transaction) async {
      DocumentReference rideRef = _firestore.collection('rides').doc(rideId);
      DocumentSnapshot rideSnapshot = await transaction.get(rideRef);

      if (!rideSnapshot.exists) {
        throw Exception("الرحلة لم تعد موجودة!");
      }

      // التحقق من الحالة لمنع التضارب
      String status = rideSnapshot.get('status');
      if (status != 'pending') {
        throw Exception("عذراً، تم قبول هذه الرحلة من قبل كابتن آخر.");
      }

      // التحديث في قاعدة البيانات
      transaction.update(rideRef, {
        'status': 'accepted',
        'driverId': driverId,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}