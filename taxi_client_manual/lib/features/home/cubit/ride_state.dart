// lib/features/home/cubit/ride_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../models/ride_model.dart';

abstract class RideState extends Equatable {
  const RideState();
  @override
  List<Object?> get props => [];
}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideRequestedSuccess extends RideState {
  final String rideId;
  const RideRequestedSuccess(this.rideId);
  @override
  List<Object?> get props => [rideId];
}

class RidePending extends RideState {
  final String rideId;
  const RidePending(this.rideId);
  @override
  List<Object?> get props => [rideId];
}

class RideActive extends RideState {
  final RideModel ride;
  final GeoPoint? driverLocation;
  const RideActive({required this.ride, this.driverLocation});
  @override
  List<Object?> get props => [ride, driverLocation];
}

class RideCompleted extends RideState {
  final RideModel ride;
  const RideCompleted(this.ride);
  @override
  List<Object?> get props => [ride];
}

class RideCancelled extends RideState {}

class RideError extends RideState {
  final String message;
  const RideError(this.message);
  @override
  List<Object?> get props => [message];
}