import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../driver_auth/domain/repositories/driver_repository_contract.dart';
import '../../../core/infrastructure/location_service.dart';
import '../../../core/infrastructure/notification_service.dart';
import 'driver_home_state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  final DriverRepositoryContract _driverRepository;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<Position>? _locationSubscription;

  // متابعة الرحلات المعلقة لإرسال الإشعارات
  StreamSubscription? _pendingRidesSubscription;
  int _previousRideCount = 0;

  DriverHomeCubit(
    this._driverRepository,
    this._auth,
    this._firestore,
  ) : super(DriverHomeInitial());

  /// الحصول على uid السائق الحالي
  String? get currentDriverId => _auth.currentUser?.uid;

  /// قراءة حالة السائق من Firestore عند فتح التطبيق
  Future<void> loadDriverStatus() async {
    final driverId = currentDriverId;
    if (driverId == null) return;

    try {
      final doc =
          await _firestore.collection('drivers').doc(driverId).get();
      if (doc.exists) {
        final status = doc.data()?['status'] ?? 'offline';
        final isOnline = status == 'online';
        if (isOnline) {
          final hasPermission =
              await LocationService.handleLocationPermission();
          if (hasPermission) {
            _startLocationTracking(driverId);
          }
          _startListeningForRides();
        }
        emit(DriverStatusUpdated(isOnline));
      }
    } catch (_) {}
  }

  Future<void> toggleDriverStatus(bool isOnline) async {
    final driverId = currentDriverId;
    if (driverId == null) return;

    try {
      if (isOnline) {
        final hasPermission = await LocationService.handleLocationPermission();
        if (!hasPermission) {
          emit(
            const DriverLocationError(
              'صلاحية الموقع مرفوضة، لا يمكن الاتصال بالخدمة',
            ),
          );
          return;
        }

        _startLocationTracking(driverId);
        _startListeningForRides();
        await _driverRepository.updateDriverStatus(driverId, 'online');
      } else {
        _locationSubscription?.cancel();
        _stopListeningForRides();
        await _driverRepository.updateDriverStatus(driverId, 'offline');
      }

      emit(DriverStatusUpdated(isOnline));
    } catch (e) {
      emit(DriverLocationError(e.toString()));
    }
  }

  /// تحديث الحالة إلى offline عند إغلاق التطبيق
  Future<void> goOffline() async {
    final driverId = currentDriverId;
    if (driverId == null) return;

    _locationSubscription?.cancel();
    _stopListeningForRides();
    try {
      await _driverRepository.updateDriverStatus(driverId, 'offline');
    } catch (_) {}
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    final driverId = currentDriverId;
    if (driverId != null) {
      await goOffline();
    }
    await _auth.signOut();
  }

  /// بدء الاستماع للرحلات المعلقة عندما يكون الكابتن online
  void _startListeningForRides() {
    _pendingRidesSubscription?.cancel();
    _previousRideCount = 0;
    _pendingRidesSubscription = _firestore
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          final currentCount = snapshot.docs.length;
          if (currentCount > _previousRideCount && _previousRideCount >= 0) {
            // إشعار جديد
            if (_previousRideCount > 0 || currentCount > 0) {
              final latestDoc = snapshot.docs.isNotEmpty
                  ? snapshot.docs.first.data()
                  : null;
              final customerName = latestDoc?['customerName'] ?? 'عميل';
              NotificationService.showNotification(
                title: 'رحلة جديدة! 🚗',
                body: 'وصل طلب رحلة جديد من $customerName',
              );
            }
          }
          _previousRideCount = currentCount;
        });
  }

  /// إيقاف الاستماع عندما يكون الكابتن offline
  void _stopListeningForRides() {
    _pendingRidesSubscription?.cancel();
    _pendingRidesSubscription = null;
    _previousRideCount = 0;
  }

  void _startLocationTracking(String driverId) {
    _locationSubscription?.cancel();
    _locationSubscription = LocationService.getPositionStream().listen((
      Position position,
    ) {
      _driverRepository.updateLocation(
        driverId: driverId,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    });
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _pendingRidesSubscription?.cancel();
    return super.close();
  }
}
