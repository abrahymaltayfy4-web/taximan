import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/infrastructure/directions_service.dart';
import 'ride_map_state.dart';

/// Cubit يدير بيانات الخريطة: موقع الكابتن + المسارات (DirectionsService)
/// الـ Views تستقبل البيانات الجاهزة وتبني منها Markers و Polylines
class RideMapCubit extends Cubit<RideMapState> {
  final DirectionsService _directionsService;
  bool _routeToPickupLoaded = false;
  bool _routeToDestinationLoaded = false;

  RideMapCubit(this._directionsService) : super(const RideMapState());

  /// جلب موقع الكابتن الحالي مع timeout لتجنب التعليق
  Future<void> loadDriverPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));
      if (!isClosed) {
        emit(state.copyWith(
          driverPosition: LatLng(pos.latitude, pos.longitude),
        ));
      }
    } catch (_) {}
  }

  /// تحميل مسار من موقع الكابتن إلى نقطة بداية العميل (عند حالة accepted)
  Future<void> loadRouteToPickup(LatLng pickup) async {
    if (_routeToPickupLoaded) return;
    if (state.driverPosition == null) {
      await loadDriverPosition();
      if (state.driverPosition == null) return;
    }

    emit(state.copyWith(isRouteLoading: true));

    final directions = await _directionsService.getDirections(
      origin: state.driverPosition!,
      destination: pickup,
    );

    if (directions != null && !isClosed) {
      _routeToPickupLoaded = true;
      emit(state.copyWith(
        routePoints: directions['polylineCoordinates'],
        distanceText: directions['distanceText'],
        durationText: directions['durationText'],
        isRouteLoading: false,
        activeRouteType: RideMapRouteType.toPickup,
      ));
    } else if (!isClosed) {
      emit(state.copyWith(isRouteLoading: false));
    }
  }

  /// تحميل مسار الرحلة من نقطة البداية إلى الوجهة (عند حالة started)
  Future<void> loadRouteToDestination(LatLng pickup, LatLng destination) async {
    if (_routeToDestinationLoaded) return;

    emit(state.copyWith(isRouteLoading: true));

    final directions = await _directionsService.getDirections(
      origin: pickup,
      destination: destination,
    );

    if (directions != null && !isClosed) {
      _routeToDestinationLoaded = true;
      emit(state.copyWith(
        routePoints: directions['polylineCoordinates'],
        distanceText: directions['distanceText'],
        durationText: directions['durationText'],
        isRouteLoading: false,
        activeRouteType: RideMapRouteType.toDestination,
      ));
    } else if (!isClosed) {
      emit(state.copyWith(isRouteLoading: false));
    }
  }

  /// تحميل مسار معاينة الرحلة (RidePreview)
  /// جلب الموقع يتم بالتوازي ولا يعيق حساب المسار
  Future<void> loadPreviewRoute(LatLng pickup, LatLng destination) async {
    // جلب موقع الكابتن بالتوازي — لا ينتظره حساب المسار
    loadDriverPosition();

    emit(state.copyWith(isRouteLoading: true));

    final directions = await _directionsService.getDirections(
      origin: pickup,
      destination: destination,
    );

    if (directions != null && !isClosed) {
      final List<LatLng> points = directions['polylineCoordinates'];
      emit(state.copyWith(
        routePoints: points,
        distanceText: directions['distanceText'],
        durationText: directions['durationText'],
        isRouteLoading: false,
        activeRouteType: RideMapRouteType.preview,
      ));
    } else if (!isClosed) {
      emit(state.copyWith(isRouteLoading: false));
    }
  }

  /// إعادة تعيين حالة المسار (عند بدء رحلة جديدة)
  void resetRoutes() {
    _routeToPickupLoaded = false;
    _routeToDestinationLoaded = false;
    emit(const RideMapState());
  }
}
