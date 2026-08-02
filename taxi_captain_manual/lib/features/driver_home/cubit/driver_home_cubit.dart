// lib/features/driver_home/cubit/driver_home_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
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

  Future<void> toggleDriverStatus(String driverId, bool isOnline) async {
    try {
      if (isOnline) {
        final hasPermission = await LocationService.handleLocationPermission();
        if (!hasPermission) {
          // تم إزالة كلمة const من هنا لتصحيح الخطأ
          emit(DriverLocationError('صلاحية الموقع مرفوضة، لا يمكن الاتصال بالخدمة'));
          return;
        }

        _startLocationTracking(driverId);
      } else {
        _locationSubscription?.cancel();
      }

      emit(DriverStatusUpdated(isOnline));
    } catch (e) {
      emit(DriverLocationError(e.toString()));
    }
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