import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideMapState extends Equatable {
  final LatLng? driverPosition;
  final List<LatLng> routePoints;
  final String? distanceText;
  final String? durationText;
  final bool isRouteLoading;
  final RideMapRouteType? activeRouteType;

  const RideMapState({
    this.driverPosition,
    this.routePoints = const [],
    this.distanceText,
    this.durationText,
    this.isRouteLoading = false,
    this.activeRouteType,
  });

  RideMapState copyWith({
    LatLng? driverPosition,
    List<LatLng>? routePoints,
    String? distanceText,
    String? durationText,
    bool? isRouteLoading,
    RideMapRouteType? activeRouteType,
  }) {
    return RideMapState(
      driverPosition: driverPosition ?? this.driverPosition,
      routePoints: routePoints ?? this.routePoints,
      distanceText: distanceText ?? this.distanceText,
      durationText: durationText ?? this.durationText,
      isRouteLoading: isRouteLoading ?? this.isRouteLoading,
      activeRouteType: activeRouteType ?? this.activeRouteType,
    );
  }

  @override
  List<Object?> get props => [
        driverPosition,
        routePoints,
        distanceText,
        durationText,
        isRouteLoading,
        activeRouteType,
      ];
}

enum RideMapRouteType { toPickup, toDestination, preview }
