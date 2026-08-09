import '../../../models/ride_model.dart';
import '../../../repositories/ride_repository.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

abstract class CaptainRideState extends Equatable {
  const CaptainRideState();

  @override
  List<Object?> get props => [];
}

class CaptainRideInitial extends CaptainRideState {}

class CaptainRideLoading extends CaptainRideState {}

class CaptainPendingRidesLoaded extends CaptainRideState {
  final List<RideModel> rides;

  const CaptainPendingRidesLoaded(this.rides);

  @override
  List<Object?> get props => [rides];
}

class CaptainPendingRidesEmpty extends CaptainRideState {}

class CaptainActiveRide extends CaptainRideState {
  final RideModel ride;

  const CaptainActiveRide(this.ride);

  @override
  List<Object?> get props => [ride];
}

class CaptainRideCompleted extends CaptainRideState {
  final RideModel ride;

  const CaptainRideCompleted(this.ride);

  @override
  List<Object?> get props => [ride];
}

class CaptainRideError extends CaptainRideState {
  final String message;

  const CaptainRideError(this.message);

  @override
  List<Object?> get props => [message];
}

class CaptainRideCubit extends Cubit<CaptainRideState> {
  final RideRepository _rideRepository;
  StreamSubscription? _pendingRidesSubscription;
  StreamSubscription? _activeRideSubscription;

  CaptainRideCubit(this._rideRepository) : super(CaptainRideInitial());

  void listenToPendingRides() {
    emit(CaptainRideLoading());
    _pendingRidesSubscription?.cancel();
    _pendingRidesSubscription = _rideRepository.streamPendingRides().listen(
      (rides) {
        if (rides.isEmpty) {
          emit(CaptainPendingRidesEmpty());
        } else {
          emit(CaptainPendingRidesLoaded(rides));
        }
      },
      onError: (e) {
        emit(CaptainRideError(e.toString()));
      },
    );
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    try {
      emit(CaptainRideLoading());
      await _rideRepository.acceptRide(rideId: rideId, driverId: driverId);
      listenToActiveRide(rideId);
    } catch (e) {
      emit(CaptainRideError(e.toString()));
    }
  }

  void listenToActiveRide(String rideId) {
    emit(CaptainRideLoading());
    _activeRideSubscription?.cancel();
    _activeRideSubscription = _rideRepository.streamRide(rideId).listen(
      (ride) {
        if (ride == null) {
          emit(const CaptainRideError('الرحلة غير موجودة'));
        } else if (ride.status == 'completed') {
          emit(CaptainRideCompleted(ride));
        } else {
          emit(CaptainActiveRide(ride));
        }
      },
      onError: (e) {
        emit(CaptainRideError(e.toString()));
      },
    );
  }

  Future<void> updateRideStatus(String rideId, String status) async {
    try {
      await _rideRepository.updateRideStatus(rideId: rideId, status: status);
    } catch (e) {
      emit(CaptainRideError(e.toString()));
    }
  }

  Future<void> completeRide(String rideId, String driverId) async {
    try {
      await _rideRepository.completeRide(rideId: rideId, driverId: driverId);
    } catch (e) {
      emit(CaptainRideError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _pendingRidesSubscription?.cancel();
    _activeRideSubscription?.cancel();
    return super.close();
  }
}
