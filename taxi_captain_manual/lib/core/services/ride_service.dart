import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// جلب إعدادات الأسعار من Firestore
  Future<Map<String, double>> _getPricingSettings() async {
    final doc = await _firestore.collection('settings').doc('pricing').get();
    if (doc.exists) {
      final data = doc.data()!;
      return {
        'pricePerKm': (data['pricePerKm'] ?? data['defaultPricePerKm'] ?? 500.0).toDouble(),
        'minimumFare': (data['minimumFare'] ?? 500.0).toDouble(),
        'commissionPercentage': (data['commissionPercentage'] ?? 10.0).toDouble(),
      };
    }
    return {'pricePerKm': 500.0, 'minimumFare': 500.0, 'commissionPercentage': 10.0};
  }

  Future<void> acceptRide({required String rideId, required String driverId}) async {
    // جلب إعدادات الأسعار الموحدة
    final pricing = await _getPricingSettings();
    final pricePerKm = pricing['pricePerKm']!;
    final minimumFare = pricing['minimumFare']!;

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

      // التحقق من حالة الحظر
      if (driverData['isBlocked'] == true) {
        throw Exception('حسابك محظور ولا يمكنك قبول رحلات. تواصل مع الإدارة.');
      }

      // حساب السعر الموحد: أقل مشوار = minimumFare
      final fare = max(minimumFare, distanceKm * pricePerKm);

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

  /// إكمال الرحلة + حساب العمولة + إنشاء سجل معاملة
  Future<void> completeRide({required String rideId, required String driverId}) async {
    final pricing = await _getPricingSettings();
    final commissionPercentage = pricing['commissionPercentage']!;

    final rideRef = _firestore.collection('rides').doc(rideId);
    final driverRef = _firestore.collection('drivers').doc(driverId);

    await _firestore.runTransaction((transaction) async {
      final rideDoc = await transaction.get(rideRef);
      final fare = (rideDoc.data()?['fare'] ?? 0.0).toDouble();
      final commission = fare * commissionPercentage / 100;

      final driverDoc = await transaction.get(driverRef);
      final currentOwed = (driverDoc.data()?['totalCommissionOwed'] ?? 0.0).toDouble();

      // تحديث الرحلة
      transaction.update(rideRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'commission': commission,
        'commissionPercentage': commissionPercentage,
      });

      // تحديث حالة السائق + إضافة العمولة
      transaction.update(driverRef, {
        'status': 'online',
        'totalCommissionOwed': currentOwed + commission,
      });
    });

    // إنشاء سجل المعاملة (خارج الـ transaction لأنه add وليس update)
    final rideDoc = await rideRef.get();
    final fare = (rideDoc.data()?['fare'] ?? 0.0).toDouble();
    final commission = fare * commissionPercentage / 100;

    await _firestore.collection('transactions').add({
      'driverId': driverId,
      'driverName': rideDoc.data()?['driverName'] ?? '',
      'type': 'commission',
      'amount': commission,
      'rideId': rideId,
      'rideFare': fare,
      'note': 'عمولة رحلة — ${commission.toStringAsFixed(0)} ريال من ${fare.toStringAsFixed(0)} ريال',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'system',
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