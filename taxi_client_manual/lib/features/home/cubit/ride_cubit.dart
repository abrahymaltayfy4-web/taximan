// lib/features/home/cubit/ride_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ride_model.dart';
import 'ride_state.dart';
import '../../../core/services/notification_service.dart';

class RideCubit extends Cubit<RideState> {
  RideCubit() : super(RideInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _rideSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _driverLocationSubscription;

  RideModel? _currentRide;
  GeoPoint? _currentDriverLocation;
  Timer? _autoCancelTimer;

  Future<void> requestRide({
    required GeoPoint pickupLocation,
    required String pickupAddress,
    required GeoPoint destinationLocation,
    required String destinationAddress,
    required double distanceKm,
  }) async {
    emit(RideLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(const RideError('يجب تسجيل الدخول أولاً'));
        return;
      }

      // جلب بيانات العميل من مجموعة clients
      final clientDoc =
          await _firestore.collection('clients').doc(user.uid).get();
      final clientData = clientDoc.data();

      // التحقق من حالة الحظر
      if (clientData?['isBlocked'] == true) {
        emit(const RideError('حسابك محظور ولا يمكنك طلب رحلات. تواصل مع الإدارة.'));
        return;
      }

      final customerName =
          clientData?['name'] ?? user.displayName ?? user.email ?? 'عميل رحال';
      final customerPhone = clientData?['phone'] ?? '';

      // جلب الأسعار الموحدة من الإعدادات
      double pricePerKm = 500.0;
      double minimumFare = 500.0;
      try {
        final pricingDoc = await _firestore.collection('settings').doc('pricing').get();
        if (pricingDoc.exists) {
          final pData = pricingDoc.data()!;
          pricePerKm = (pData['pricePerKm'] ?? pData['defaultPricePerKm'] ?? 500.0).toDouble();
          minimumFare = (pData['minimumFare'] ?? 500.0).toDouble();
        }
      } catch (_) {}

      // حساب السعر: أقل مشوار = minimumFare
      final fare = distanceKm * pricePerKm < minimumFare ? minimumFare : distanceKm * pricePerKm;

      final rideData = <String, dynamic>{
        'customerId': user.uid,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'driverId': null,
        'driverName': null,
        'driverPhone': null,
        'driverCarModel': null,
        'driverCarPlate': null,
        'pickupLocation': pickupLocation,
        'pickupAddress': pickupAddress,
        'destinationLocation': destinationLocation,
        'destinationAddress': destinationAddress,
        'status': 'pending',
        'fare': fare,
        'distanceKm': distanceKm,
        'createdAt': FieldValue.serverTimestamp(),
        'acceptedAt': null,
        'completedAt': null,
      };

      DocumentReference docRef =
          await _firestore.collection('rides').add(rideData);

      emit(RideRequestedSuccess(docRef.id));
    } catch (e) {
      emit(RideError('حدث خطأ أثناء طلب الرحلة: ${e.toString()}'));
    }
  }

  void listenToRideStatus(String rideId) {
    _rideSubscription?.cancel();
    _rideSubscription = _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return;

      final ride = RideModel.fromJson(snapshot.data()!, snapshot.id);
      _currentRide = ride;

      switch (ride.status) {
        case 'pending':
          _autoCancelTimer?.cancel();
          _autoCancelTimer = Timer(const Duration(minutes: 3), () {
            if (_currentRide?.status == 'pending' || state is RidePending) {
              cancelRide(rideId);
            }
          });
          emit(RidePending(rideId));
          break;
        case 'accepted':
          _autoCancelTimer?.cancel();
          NotificationService.showNotification(
            title: 'تم قبول طلبك!',
            body: 'الكابتن ${ride.driverName ?? ''} في طريقه إليك',
          );
        case 'driver_arrived':
          NotificationService.showNotification(
            title: 'الكابتن وصل! 🚗',
            body: 'الكابتن ${ride.driverName ?? ''} وصل لموقعك',
          );
        case 'started':
          NotificationService.showNotification(
            title: 'الرحلة بدأت! 🛣️',
            body: 'رحلتك مع الكابتن ${ride.driverName ?? ''} بدأت الآن',
          );
          // بدء الاستماع لموقع السائق إذا كان لديه driverId ولم نبدأ الاستماع بعد
          if (ride.driverId != null &&
              _driverLocationSubscription == null) {
            _listenToDriverLocation(ride.driverId!);
          }
          emit(RideActive(
              ride: ride, driverLocation: _currentDriverLocation));
          break;
        case 'completed':
          _autoCancelTimer?.cancel();
          _driverLocationSubscription?.cancel();
          _driverLocationSubscription = null;
          emit(RideCompleted(ride));
          break;
        case 'cancelled':
          _autoCancelTimer?.cancel();
          _driverLocationSubscription?.cancel();
          _driverLocationSubscription = null;
          emit(RideCancelled());
          break;
        default:
          emit(RideActive(
              ride: ride, driverLocation: _currentDriverLocation));
      }
    }, onError: (e) {
      emit(RideError('خطأ في تتبع الرحلة: ${e.toString()}'));
    });
  }

  void _listenToDriverLocation(String driverId) {
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = _firestore
        .collection('drivers')
        .doc(driverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final location = snapshot.data()!['location'] as GeoPoint?;
        if (location != null) {
          _currentDriverLocation = location;
          if (_currentRide != null &&
              _currentRide!.status != 'completed' &&
              _currentRide!.status != 'cancelled') {
            emit(RideActive(
                ride: _currentRide!, driverLocation: location));
          }
        }
      }
    });
  }

  Future<void> cancelRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      emit(RideError('حدث خطأ أثناء إلغاء الرحلة: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _autoCancelTimer?.cancel();
    _rideSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    return super.close();
  }
}