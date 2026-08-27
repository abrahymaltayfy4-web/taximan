// lib/features/driver_home/cubit/driver_home_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../repositories/driver_repository.dart';
import '../../../core/services/location_service.dart';

abstract class DriverHomeState extends Equatable {
  const DriverHomeState();
  @override
  List<Object?> get props => [];
}

class DriverHomeInitial extends DriverHomeState {}
class DriverStatusUpdated extends DriverHomeState {
  final bool isOnline;
  const DriverStatusUpdated(this.isOnline);
  @override
  List<Object?> get props => [isOnline];
}
class DriverLocationError extends DriverHomeState {
  final String message;
  const DriverLocationError(this.message);
  @override
  List<Object?> get props => [message];
}

class DriverHomeCubit extends Cubit<DriverHomeState> {
  final DriverRepository _driverRepository;
  StreamSubscription<Position>? _locationSubscription;

  DriverHomeCubit(this._driverRepository) : super(DriverHomeInitial());

  /// قراءة حالة السائق من Firestore عند فتح التطبيق
  Future<void> loadDriverStatus(String driverId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();
      if (doc.exists) {
        final status = doc.data()?['status'] ?? 'offline';
        final isOnline = status == 'online';
        if (isOnline) {
          // إعادة تشغيل تتبع الموقع
          final hasPermission = await LocationService.handleLocationPermission();
          if (hasPermission) {
            _startLocationTracking(driverId);
          }
        }
        emit(DriverStatusUpdated(isOnline));
      }
    } catch (_) {}
  }

  Future<void> toggleDriverStatus(String driverId, bool isOnline) async {
    try {
      if (isOnline) {
        final hasPermission = await LocationService.handleLocationPermission();
        if (!hasPermission) {
          emit(DriverLocationError('صلاحية الموقع مرفوضة، لا يمكن الاتصال بالخدمة'));
          return;
        }

        _startLocationTracking(driverId);
        await _driverRepository.updateDriverStatus(driverId, 'online');
      } else {
        _locationSubscription?.cancel();
        await _driverRepository.updateDriverStatus(driverId, 'offline');
      }

      emit(DriverStatusUpdated(isOnline));
    } catch (e) {
      emit(DriverLocationError(e.toString()));
    }
  }

  /// تحديث الحالة إلى offline عند إغلاق التطبيق
  Future<void> goOffline(String driverId) async {
    _locationSubscription?.cancel();
    try {
      await _driverRepository.updateDriverStatus(driverId, 'offline');
    } catch (_) {}
  }

  void _startLocationTracking(String driverId) {
    _locationSubscription?.cancel();
    _locationSubscription = LocationService.getPositionStream().listen((Position position) {
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
    return super.close();
  }
}