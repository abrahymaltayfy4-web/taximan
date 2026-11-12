import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

/// حالة تحديث الماركرز للسائقين القريبين
class NearbyDriversUpdated extends HomeState {
  final Set<Marker> driverMarkers;
  const NearbyDriversUpdated(this.driverMarkers);
  @override
  List<Object?> get props => [driverMarkers];
}

/// حالة نجاح حساب المسار
class HomeRouteCalculated extends HomeState {
  final List<LatLng> routePoints;
  final double distanceKm;
  final String distanceText;
  final String durationText;
  final LatLng destinationPosition;

  const HomeRouteCalculated({
    required this.routePoints,
    required this.distanceKm,
    required this.distanceText,
    required this.durationText,
    required this.destinationPosition,
  });

  @override
  List<Object?> get props => [
        routePoints,
        distanceKm,
        distanceText,
        durationText,
        destinationPosition,
      ];
}

/// حالة تحميل المسار
class HomeRouteLoading extends HomeState {}

/// خطأ في تحميل السائقين القريبين
class NearbyDriversError extends HomeState {
  final String message;
  const NearbyDriversError(this.message);
  @override
  List<Object?> get props => [message];
}

/// خطأ في حساب المسار
class HomeRouteError extends HomeState {
  final String message;
  const HomeRouteError(this.message);
  @override
  List<Object?> get props => [message];
}
