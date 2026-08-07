// lib/features/home/cubit/ride_state.dart
abstract class RideState {}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideRequestedSuccess extends RideState {
  final String rideId;
  RideRequestedSuccess(this.rideId);
}

class RideError extends RideState {
  final String message;
  RideError(this.message);
}