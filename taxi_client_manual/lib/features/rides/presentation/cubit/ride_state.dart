import 'package:equatable/equatable.dart';
import '../../domain/entities/ride_entity.dart';
import '../../../../core/domain/location_entity.dart';

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
  final RideEntity ride;
  final LocationEntity? driverLocation;
  const RideActive({required this.ride, this.driverLocation});
  @override
  List<Object?> get props => [ride, driverLocation];
}

class RideCompleted extends RideState {
  final RideEntity ride;
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
