import 'package:equatable/equatable.dart';
import '../../domain/entities/ride_entity.dart';

/// حالات Cubit الرحلات — Presentation Layer
abstract class CaptainRideState extends Equatable {
  const CaptainRideState();

  @override
  List<Object?> get props => [];
}

class CaptainRideInitial extends CaptainRideState {}

class CaptainRideLoading extends CaptainRideState {}

class CaptainPendingRidesLoaded extends CaptainRideState {
  final List<RideEntity> rides;

  const CaptainPendingRidesLoaded(this.rides);

  @override
  List<Object?> get props => [rides];
}

class CaptainPendingRidesEmpty extends CaptainRideState {}

class CaptainActiveRide extends CaptainRideState {
  final RideEntity ride;

  const CaptainActiveRide(this.ride);

  @override
  List<Object?> get props => [ride];
}

class CaptainRideCompleted extends CaptainRideState {
  final RideEntity ride;

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
