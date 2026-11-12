import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/infrastructure/directions_service.dart';
import 'home_state.dart';

/// Cubit يدير الصفحة الرئيسية للعميل
/// يتولى الاستماع للسائقين القريبين وحساب المسارات
class HomeCubit extends Cubit<HomeState> {
  final FirebaseFirestore _firestore;
  final DirectionsService _directionsService;
  StreamSubscription? _driversSubscription;

  HomeCubit(this._firestore, this._directionsService) : super(HomeInitial());

  /// بدء الاستماع للسائقين القريبين
  void listenToNearbyDrivers(LatLng currentPosition) {
    _driversSubscription?.cancel();
    _driversSubscription = _firestore
        .collection('drivers')
        .where('status', isEqualTo: 'online')
        .snapshots()
        .listen((snapshot) {
          final Set<Marker> driverMarkers = {};

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final location = data['location'];
            if (location is GeoPoint) {
              final driverLatLng = LatLng(
                location.latitude,
                location.longitude,
              );
              final distance = _calculateDistance(
                currentPosition.latitude,
                currentPosition.longitude,
                driverLatLng.latitude,
                driverLatLng.longitude,
              );
              if (distance <= 2.0) {
                driverMarkers.add(
                  Marker(
                    markerId: MarkerId('driver_${doc.id}'),
                    position: driverLatLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    infoWindow: InfoWindow(
                      title: data['name'] ?? 'كابتن',
                      snippet: '${data['carModel'] ?? ''}',
                    ),
                  ),
                );
              }
            }
          }

          emit(NearbyDriversUpdated(driverMarkers));
        }, onError: (e) {
          emit(NearbyDriversError(e.toString()));
        });
  }

  /// حساب المسار بين نقطتين عبر DirectionsService
  Future<void> calculateRoute({
    required LatLng pickup,
    required LatLng destination,
  }) async {
    emit(HomeRouteLoading());
    try {
      final directionsData = await _directionsService.getDirections(
        origin: pickup,
        destination: destination,
      );

      if (directionsData != null && !isClosed) {
        final List<LatLng> points = directionsData['polylineCoordinates'];
        emit(HomeRouteCalculated(
          routePoints: points,
          distanceKm: directionsData['distanceValue'],
          distanceText: directionsData['distanceText'],
          durationText: directionsData['durationText'],
          destinationPosition: destination,
        ));
      } else if (!isClosed) {
        emit(const HomeRouteError('تعذر حساب المسار'));
      }
    } catch (e) {
      if (!isClosed) {
        emit(HomeRouteError(e.toString()));
      }
    }
  }

  /// حساب المسافة بين نقطتين بصيغة Haversine (كم)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  @override
  Future<void> close() {
    _driversSubscription?.cancel();
    return super.close();
  }
}
