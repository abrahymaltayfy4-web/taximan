// lib/features/driver_home/cubit/driver_home_state.dart
import 'package:equatable/equatable.dart';

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
