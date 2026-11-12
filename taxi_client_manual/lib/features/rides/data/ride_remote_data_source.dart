import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/location_entity.dart';
import '../domain/ride_entity.dart';
import 'ride_mapper.dart';
import '../../../core/shared/pricing_config.dart';
import '../../../core/shared/account_status.dart';

/// مصدر بيانات الرحلات من Firestore — Data Layer فقط
class RideRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RideRemoteDataSource(this._firestore, this._auth);

  /// جلب بيانات المستخدم الحالي
  User? get currentUser => _auth.currentUser;

  /// جلب بيانات العميل
  Future<Map<String, dynamic>?> getClientData(String uid) async {
    final doc = await _firestore.collection('clients').doc(uid).get();
    return doc.data();
  }

  /// جلب إعدادات التسعير
  Future<PricingConfig> getPricingConfig() async {
    try {
      final doc = await _firestore.collection('settings').doc('pricing').get();
      if (doc.exists) {
        return PricingConfig.fromMap(doc.data()!);
      }
    } catch (_) {}
    return const PricingConfig();
  }

  /// إنشاء رحلة جديدة في Firestore — يعيد الـ document ID
  Future<String> createRide({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required LocationEntity pickupLocation,
    required String pickupAddress,
    required LocationEntity destinationLocation,
    required String destinationAddress,
    required double fare,
    required double distanceKm,
  }) async {
    final docRef = await _firestore.collection('rides').add({
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'driverId': null,
      'driverName': null,
      'driverPhone': null,
      'driverCarModel': null,
      'driverCarPlate': null,
      'pickupLocation': RideMapper.locationToGeoPoint(pickupLocation),
      'pickupAddress': pickupAddress,
      'destinationLocation': RideMapper.locationToGeoPoint(destinationLocation),
      'destinationAddress': destinationAddress,
      'status': 'pending',
      'fare': fare,
      'distanceKm': distanceKm,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': null,
      'completedAt': null,
    });
    return docRef.id;
  }

  /// مراقبة رحلة بالـ ID
  Stream<RideEntity?> watchRide(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return RideMapper.fromFirestore(snapshot.data()!, snapshot.id);
    });
  }

  /// مراقبة موقع السائق
  Stream<LocationEntity?> watchDriverLocation(String driverId) {
    return _firestore.collection('drivers').doc(driverId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return RideMapper.driverLocationFromFirestore(snapshot.data());
    });
  }

  /// إلغاء رحلة
  Future<void> cancelRide(String rideId) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': 'cancelled',
    });
  }

  /// جلب سجل رحلات العميل
  Future<List<RideEntity>> getRideHistory(String customerId) async {
    final snapshot = await _firestore
        .collection('rides')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => RideMapper.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// فحص حالة حساب العميل
  AccountStatus getAccountStatus(Map<String, dynamic>? data) {
    if (data == null) return AccountStatus.active;
    if (data['accountStatus'] != null) {
      return AccountStatus.fromString(data['accountStatus']);
    }
    if (data['isBlocked'] == true) return AccountStatus.blocked;
    return AccountStatus.active;
  }
}
