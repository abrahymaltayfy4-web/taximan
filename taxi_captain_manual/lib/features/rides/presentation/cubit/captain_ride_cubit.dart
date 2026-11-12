import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/failure_messages.dart';
import '../../../../core/infrastructure/notification_service.dart';
import '../../domain/usecases/watch_pending_rides_use_case.dart';
import '../../domain/usecases/accept_ride_use_case.dart';
import '../../domain/usecases/complete_ride_use_case.dart';
import '../../domain/usecases/update_ride_status_use_case.dart';
import '../../domain/usecases/watch_active_ride_use_case.dart';
import 'captain_ride_state.dart';

/// Cubit الرحلات — يستخدم Use Cases فقط، لا Firebase مباشرة في Views
class CaptainRideCubit extends Cubit<CaptainRideState> {
  final WatchPendingRidesUseCase _watchPendingRides;
  final AcceptRideUseCase _acceptRide;
  final CompleteRideUseCase _completeRide;
  final UpdateRideStatusUseCase _updateRideStatus;
  final WatchActiveRideUseCase _watchActiveRide;
  final FirebaseAuth _auth;

  StreamSubscription? _pendingRidesSubscription;
  StreamSubscription? _activeRideSubscription;
  int _previousRideCount = 0;

  CaptainRideCubit({
    required WatchPendingRidesUseCase watchPendingRides,
    required AcceptRideUseCase acceptRide,
    required CompleteRideUseCase completeRide,
    required UpdateRideStatusUseCase updateRideStatus,
    required WatchActiveRideUseCase watchActiveRide,
    required FirebaseAuth auth,
  })  : _watchPendingRides = watchPendingRides,
        _acceptRide = acceptRide,
        _completeRide = completeRide,
        _updateRideStatus = updateRideStatus,
        _watchActiveRide = watchActiveRide,
        _auth = auth,
        super(CaptainRideInitial());

  /// الحصول على uid السائق الحالي
  String get currentDriverId => _auth.currentUser?.uid ?? '';

  /// بدء الاستماع للرحلات المعلقة مع جلب الموقع تلقائياً
  /// الـ View لا تتعامل مع Geolocator مباشرة
  Future<void> startListeningWithLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      listenToPendingRides(
        driverLat: pos.latitude,
        driverLng: pos.longitude,
      );
    } catch (_) {
      listenToPendingRides();
    }
  }

  void listenToPendingRides({double? driverLat, double? driverLng}) {
    emit(CaptainRideLoading());
    _pendingRidesSubscription?.cancel();
    _pendingRidesSubscription = _watchPendingRides(
      driverLat: driverLat,
      driverLng: driverLng,
    ).listen(
      (rides) {
        if (rides.length > _previousRideCount && _previousRideCount > 0) {
          NotificationService.showNotification(
            title: 'رحلة جديدة!',
            body: 'وصل طلب رحلة جديد من ${rides.first.customerName}',
          );
        }
        _previousRideCount = rides.length;

        if (rides.isEmpty) {
          emit(CaptainPendingRidesEmpty());
        } else {
          emit(CaptainPendingRidesLoaded(rides));
        }
      },
      onError: (e) {
        emit(CaptainRideError(e.toString()));
      },
    );
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    emit(CaptainRideLoading());
    final result = await _acceptRide(rideId: rideId, driverId: driverId);
    switch (result) {
      case Success():
        listenToActiveRide(rideId);
      case Err(failure: final f):
        emit(CaptainRideError(FailureMessages.arabicMessage(f)));
    }
  }

  void listenToActiveRide(String rideId) {
    emit(CaptainRideLoading());
    _activeRideSubscription?.cancel();
    _activeRideSubscription = _watchActiveRide(rideId).listen(
      (ride) {
        if (ride == null) {
          emit(const CaptainRideError('الرحلة غير موجودة'));
        } else if (ride.status == 'completed') {
          emit(CaptainRideCompleted(ride));
        } else {
          emit(CaptainActiveRide(ride));
        }
      },
      onError: (e) {
        emit(CaptainRideError(e.toString()));
      },
    );
  }

  Future<void> updateRideStatus(String rideId, String status) async {
    final result = await _updateRideStatus(
      rideId: rideId,
      newStatus: status,
    );
    switch (result) {
      case Success():
        break;
      case Err(failure: final f):
        emit(CaptainRideError(FailureMessages.arabicMessage(f)));
    }
  }

  Future<void> completeRide(String rideId, String driverId) async {
    final result = await _completeRide(rideId: rideId, driverId: driverId);
    switch (result) {
      case Success():
        break;
      case Err(failure: final f):
        emit(CaptainRideError(FailureMessages.arabicMessage(f)));
    }
  }

  @override
  Future<void> close() {
    _pendingRidesSubscription?.cancel();
    _activeRideSubscription?.cancel();
    return super.close();
  }
}
