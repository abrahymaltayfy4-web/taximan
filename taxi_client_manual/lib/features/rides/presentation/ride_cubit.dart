import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/ride_entity.dart';
import '../domain/location_entity.dart';
import '../domain/request_ride_use_case.dart';
import '../domain/watch_active_ride_use_case.dart';
import '../domain/cancel_ride_use_case.dart';
import '../../../core/error/result.dart';
import '../../../core/error/failure_messages.dart';
import '../../../core/infrastructure/directions_service.dart';
import 'ride_state.dart';

/// دالة إرسال إشعار — قابلة للاستبدال في الاختبارات
typedef ShowNotification =
    Future<void> Function({required String title, required String body});

/// دالة إشعار فارغة للاختبارات
Future<void> _noOpNotification({
  required String title,
  required String body,
}) async {}

/// Cubit الرحلات — يعتمد على Use Cases فقط
/// لا يوجد أي import لـ Firebase
class RideCubit extends Cubit<RideState> {
  final RequestRideUseCase _requestRide;
  final WatchActiveRideUseCase _watchActiveRide;
  final CancelRideUseCase _cancelRide;
  final ShowNotification _showNotification;
  final DirectionsService? _directionsService;

  StreamSubscription? _rideSubscription;
  StreamSubscription? _driverLocationSubscription;
  Timer? _autoCancelTimer;

  RideEntity? _currentRide;
  LocationEntity? _currentDriverLocation;

  RideCubit({
    required RequestRideUseCase requestRide,
    required WatchActiveRideUseCase watchActiveRide,
    required CancelRideUseCase cancelRide,
    ShowNotification? showNotification,
    DirectionsService? directionsService,
  }) : _requestRide = requestRide,
       _watchActiveRide = watchActiveRide,
       _cancelRide = cancelRide,
       _showNotification = showNotification ?? _noOpNotification,
       _directionsService = directionsService,
       super(RideInitial());

  Future<void> requestRide({
    required LocationEntity pickupLocation,
    required String pickupAddress,
    required LocationEntity destinationLocation,
    required String destinationAddress,
    required double distanceKm,
  }) async {
    emit(RideLoading());
    final result = await _requestRide(
      pickupLocation: pickupLocation,
      pickupAddress: pickupAddress,
      destinationLocation: destinationLocation,
      destinationAddress: destinationAddress,
      distanceKm: distanceKm,
    );
    switch (result) {
      case Success(data: final rideId):
        emit(RideRequestedSuccess(rideId));
      case Err(failure: final f):
        emit(RideError(FailureMessages.arabicMessage(f)));
    }
  }

  void listenToRideStatus(String rideId) {
    _rideSubscription?.cancel();
    _rideSubscription = _watchActiveRide(rideId).listen((result) {
      switch (result) {
        case Success(data: final ride):
          _handleRideUpdate(ride, rideId);
        case Err(failure: final f):
          emit(RideError(FailureMessages.arabicMessage(f)));
      }
    });
  }

  void _handleRideUpdate(RideEntity ride, String rideId) {
    _currentRide = ride;

    switch (ride.status) {
      case 'pending':
        _autoCancelTimer?.cancel();
        _autoCancelTimer = Timer(const Duration(minutes: 3), () {
          if (_currentRide?.status == 'pending' || state is RidePending) {
            cancelRide(rideId);
          }
        });
        emit(RidePending(rideId));

      case 'accepted':
        _autoCancelTimer?.cancel();
        _showNotification(
          title: 'تم قبول طلبك!',
          body: 'الكابتن ${ride.driverName ?? ''} في طريقه إليك',
        );
        if (ride.driverId != null && _driverLocationSubscription == null) {
          _startWatchingDriverLocation(ride.driverId!);
        }
        emit(RideActive(ride: ride, driverLocation: _currentDriverLocation));

      case 'driver_arrived':
        _showNotification(
          title: 'الكابتن وصل! 🚗',
          body: 'الكابتن ${ride.driverName ?? ''} وصل لموقعك',
        );
        emit(RideActive(ride: ride, driverLocation: _currentDriverLocation));

      case 'started':
        _showNotification(
          title: 'الرحلة بدأت! 🛣️',
          body: 'رحلتك مع الكابتن ${ride.driverName ?? ''} بدأت الآن',
        );
        if (ride.driverId != null && _driverLocationSubscription == null) {
          _startWatchingDriverLocation(ride.driverId!);
        }
        emit(RideActive(ride: ride, driverLocation: _currentDriverLocation));

      case 'completed':
        _autoCancelTimer?.cancel();
        _driverLocationSubscription?.cancel();
        _driverLocationSubscription = null;
        emit(RideCompleted(ride));

      case 'cancelled':
        _autoCancelTimer?.cancel();
        _driverLocationSubscription?.cancel();
        _driverLocationSubscription = null;
        emit(RideCancelled());

      default:
        emit(RideActive(ride: ride, driverLocation: _currentDriverLocation));
    }
  }

  void _startWatchingDriverLocation(String driverId) {
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = _watchActiveRide
        .watchDriverLocation(driverId)
        .listen((result) {
          switch (result) {
            case Success(data: final location):
              _currentDriverLocation = location;
              if (_currentRide != null && _currentRide!.isActive) {
                emit(RideActive(ride: _currentRide!, driverLocation: location));
              }
            case Err():
              break;
          }
        });
  }

  Future<void> cancelRide(String rideId) async {
    final result = await _cancelRide(rideId);
    switch (result) {
      case Success():
        break;
      case Err(failure: final f):
        emit(RideError(FailureMessages.arabicMessage(f)));
    }
  }

  /// حساب المسار بين نقطتين لرسمه على الخريطة
  Future<void> calculateRoute(LatLng pickup, LatLng destination) async {
    final ds = _directionsService;
    if (ds == null) return;
    final data = await ds.getDirections(
      origin: pickup,
      destination: destination,
    );
    if (data != null && !isClosed) {
      final List<LatLng> points = data['polylineCoordinates'];
      emit(RideRouteLoaded(points));
    }
  }

  @override
  Future<void> close() {
    _autoCancelTimer?.cancel();
    _rideSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    return super.close();
  }
}
