// lib/features/driver_home/cubit/driver_home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../repositories/driver_repository.dart';

// States
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

// Cubit
class DriverHomeCubit extends Cubit<DriverHomeState> {
  final DriverRepository _driverRepository;

  DriverHomeCubit(this._driverRepository) : super(DriverHomeInitial());

  // Toggle driver online / offline status
  Future<void> toggleDriverStatus(String driverId, bool isOnline) async {
    try {
      final status = isOnline ? 'online' : 'offline';
      // Here we update status in Firestore via repository if needed
      emit(DriverStatusUpdated(isOnline));
    } catch (e) {
      emit(DriverLocationError(e.toString()));
    }
  }

  // Update live GPS coordinates
  Future<void> updateLocation(String driverId, double lat, double lng) async {
    try {
      await _driverRepository.updateLocation(
        driverId: driverId,
        latitude: lat,
        longitude: lng,
      );
    } catch (e) {
      // Handle location update error silently or log it
    }
  }
}