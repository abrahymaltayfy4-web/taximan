import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/location_entity.dart';
import '../../../../core/domain/ride_status.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../core/error/result.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/usecases/cancel_ride_use_case.dart';
import '../../domain/usecases/request_ride_use_case.dart';
import '../../domain/usecases/watch_active_ride_use_case.dart';
import 'ride_state.dart';

/// Cubit الرحلات (العميل) — يعتمد على Use Cases فقط ولا يعرف Firebase.
class RideCubit extends Cubit<RideState> {
  static const Duration autoCancelAfter = Duration(minutes: 3);

  final RequestRideUseCase _requestRide;
  final WatchActiveRideUseCase _watchActiveRide;
  final CancelRideUseCase _cancelRide;
  final NotificationService _notifications;

  StreamSubscription<Result<RideEntity>>? _rideSubscription;
  StreamSubscription<Result<LocationEntity>>? _driverLocationSubscription;
  Timer? _autoCancelTimer;

  RideEntity? _currentRide;
  LocationEntity? _currentDriverLocation;

  RideCubit({
    required RequestRideUseCase requestRide,
    required WatchActiveRideUseCase watchActiveRide,
    required CancelRideUseCase cancelRide,
    required NotificationService notifications,
  }) : _requestRide = requestRide,
       _watchActiveRide = watchActiveRide,
       _cancelRide = cancelRide,
       _notifications = notifications,
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
      case RideStatus.pending:
        _autoCancelTimer?.cancel();
        _autoCancelTimer = Timer(autoCancelAfter, () {
          if (_currentRide?.status == RideStatus.pending ||
              state is RidePending) {
            cancelRide(rideId);
          }
        });
        emit(RidePending(rideId));

      case RideStatus.accepted:
        _autoCancelTimer?.cancel();
        _notifications.show(
          title: 'تم قبول طلبك!',
          body: 'الكابتن ${ride.driverName ?? ''} في طريقه إليك',
        );
        _watchDriverIfNeeded(ride);
        emit(RideActive(ride: ride, driverLocation: _currentDriverLocation));

      case RideStatus.driverArrived:
        _notifications.show(
          title: 'الكابتن وصل! 🚗',
          body: 'الكابتن ${ride.driverName ?? ''} وصل لموقعك',
        );
        emit(RideActive(ride: ride, driverLocation: _currentDriverLocation));

      case RideStatus.started:
        _notifications.show(
          title: 'الرحلة بدأت! 🛣️',
          body: 'رحلتك مع الكابتن ${ride.driverName ?? ''} بدأت الآن',
        );
        _watchDriverIfNeeded(ride);
        emit(RideActive(ride: ride, driverLocation: _currentDriverLocation));

      case RideStatus.completed:
        _autoCancelTimer?.cancel();
        _stopWatchingDriver();
        emit(RideCompleted(ride));

      case RideStatus.cancelled:
        _autoCancelTimer?.cancel();
        _stopWatchingDriver();
        emit(RideCancelled());
    }
  }

  void _watchDriverIfNeeded(RideEntity ride) {
    if (ride.driverId != null && _driverLocationSubscription == null) {
      _startWatchingDriverLocation(ride.driverId!);
    }
  }

  void _startWatchingDriverLocation(String driverId) {
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = _watchActiveRide
        .watchDriverLocation(driverId)
        .listen((result) {
          if (result case Success(data: final location)) {
            _currentDriverLocation = location;
            final ride = _currentRide;
            if (ride != null && ride.isActive) {
              emit(RideActive(ride: ride, driverLocation: location));
            }
          }
        });
  }

  void _stopWatchingDriver() {
    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = null;
  }

  Future<void> cancelRide(String rideId) async {
    final result = await _cancelRide(rideId);
    if (result case Err(failure: final f)) {
      emit(RideError(FailureMessages.arabicMessage(f)));
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
