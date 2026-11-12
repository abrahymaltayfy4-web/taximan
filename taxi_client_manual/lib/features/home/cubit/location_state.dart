import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// حالات الأذونات
enum LocationPermissionStatus {
  initial,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

class LocationState extends Equatable {
  final LatLng? currentPosition;
  final LocationPermissionStatus permissionStatus;
  final String? errorMessage;

  const LocationState({
    this.currentPosition,
    this.permissionStatus = LocationPermissionStatus.initial,
    this.errorMessage,
  });

  LocationState copyWith({
    LatLng? currentPosition,
    LocationPermissionStatus? permissionStatus,
    String? errorMessage,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      permissionStatus: permissionStatus ?? this.permissionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [currentPosition, permissionStatus, errorMessage];
}
