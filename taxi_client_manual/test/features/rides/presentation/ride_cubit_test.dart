import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:taxi_client_manual/core/error/result.dart';
import 'package:taxi_client_manual/features/rides/domain/customer_ride_repository.dart';
import 'package:taxi_client_manual/features/rides/domain/ride_entity.dart';
import 'package:taxi_client_manual/features/rides/domain/location_entity.dart';
import 'package:taxi_client_manual/features/rides/domain/request_ride_use_case.dart';
import 'package:taxi_client_manual/features/rides/domain/watch_active_ride_use_case.dart';
import 'package:taxi_client_manual/features/rides/domain/cancel_ride_use_case.dart';
import 'package:taxi_client_manual/features/rides/presentation/ride_cubit.dart';
import 'package:taxi_client_manual/features/rides/presentation/ride_state.dart';

// ═══════════════════════════════════════════
// Fake Repository
// ═══════════════════════════════════════════
class FakeRideRepository implements CustomerRideRepository {
  Result<String>? requestRideResult;
  Result<void>? cancelRideResult;
  Result<List<RideEntity>>? loadHistoryResult;
  final StreamController<Result<RideEntity>> rideController =
      StreamController<Result<RideEntity>>.broadcast();
  final StreamController<Result<LocationEntity>> driverLocationController =
      StreamController<Result<LocationEntity>>.broadcast();

  @override
  Future<Result<String>> requestRide({
    required LocationEntity pickupLocation,
    required String pickupAddress,
    required LocationEntity destinationLocation,
    required String destinationAddress,
    required double distanceKm,
  }) async =>
      requestRideResult ?? Result.failure(const UnknownFailure('not set'));

  @override
  Stream<Result<RideEntity>> watchActiveRide(String rideId) =>
      rideController.stream;

  @override
  Stream<Result<LocationEntity>> watchDriverLocation(String driverId) =>
      driverLocationController.stream;

  @override
  Future<Result<void>> cancelRide(String rideId) async =>
      cancelRideResult ?? Result.failure(const UnknownFailure('not set'));

  @override
  Future<Result<List<RideEntity>>> loadRideHistory() async =>
      loadHistoryResult ?? Result.failure(const UnknownFailure('not set'));

  void dispose() {
    rideController.close();
    driverLocationController.close();
  }
}

// ═══════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════
const _pickup = LocationEntity(latitude: 24.7, longitude: 46.7);
const _dest = LocationEntity(latitude: 24.8, longitude: 46.8);

RideEntity _makeRide({String status = 'pending', String? driverId}) {
  return RideEntity(
    rideId: 'ride-1',
    customerId: 'c-1',
    customerName: 'عميل',
    customerPhone: '0500000000',
    driverId: driverId,
    driverName: driverId != null ? 'كابتن' : null,
    pickupLocation: _pickup,
    pickupAddress: 'شارع الملك فهد',
    destinationLocation: _dest,
    destinationAddress: 'مطار الرياض',
    status: status,
    fare: 1000,
    distanceKm: 2.0,
    createdAt: DateTime(2024, 1, 1),
  );
}

void main() {
  late FakeRideRepository repo;

  setUp(() => repo = FakeRideRepository());
  tearDown(() => repo.dispose());

  RideCubit buildCubit() => RideCubit(
    requestRide: RequestRideUseCase(repo),
    watchActiveRide: WatchActiveRideUseCase(repo),
    cancelRide: CancelRideUseCase(repo),
  );

  group('RideCubit.requestRide', () {
    blocTest<RideCubit, RideState>(
      'نجاح → Loading ثم RequestedSuccess',
      build: () {
        repo.requestRideResult = Result.success('ride-123');
        return buildCubit();
      },
      act: (cubit) => cubit.requestRide(
        pickupLocation: _pickup,
        pickupAddress: 'test',
        destinationLocation: _dest,
        destinationAddress: 'test',
        distanceKm: 2.0,
      ),
      expect: () => [
        isA<RideLoading>(),
        isA<RideRequestedSuccess>().having(
          (s) => s.rideId,
          'rideId',
          'ride-123',
        ),
      ],
    );

    blocTest<RideCubit, RideState>(
      'فشل → Loading ثم Error',
      build: () {
        repo.requestRideResult = Result.failure(const AuthFailure());
        return buildCubit();
      },
      act: (cubit) => cubit.requestRide(
        pickupLocation: _pickup,
        pickupAddress: 'test',
        destinationLocation: _dest,
        destinationAddress: 'test',
        distanceKm: 2.0,
      ),
      expect: () => [
        isA<RideLoading>(),
        isA<RideError>().having((s) => s.message, 'msg', 'يجب تسجيل الدخول'),
      ],
    );
  });

  group('RideCubit.listenToRideStatus', () {
    blocTest<RideCubit, RideState>(
      'pending → RidePending',
      build: buildCubit,
      act: (cubit) {
        cubit.listenToRideStatus('ride-1');
        repo.rideController.add(Result.success(_makeRide(status: 'pending')));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [isA<RidePending>()],
    );

    blocTest<RideCubit, RideState>(
      'completed → RideCompleted',
      build: buildCubit,
      act: (cubit) {
        cubit.listenToRideStatus('ride-1');
        repo.rideController.add(Result.success(_makeRide(status: 'completed')));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [isA<RideCompleted>()],
    );

    blocTest<RideCubit, RideState>(
      'cancelled → RideCancelled',
      build: buildCubit,
      act: (cubit) {
        cubit.listenToRideStatus('ride-1');
        repo.rideController.add(Result.success(_makeRide(status: 'cancelled')));
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [isA<RideCancelled>()],
    );

    blocTest<RideCubit, RideState>(
      'accepted → RideActive',
      build: buildCubit,
      act: (cubit) {
        cubit.listenToRideStatus('ride-1');
        repo.rideController.add(
          Result.success(_makeRide(status: 'accepted', driverId: 'd-1')),
        );
      },
      wait: const Duration(milliseconds: 100),
      expect: () => [isA<RideActive>()],
    );
  });

  group('RideCubit.cancelRide', () {
    blocTest<RideCubit, RideState>(
      'فشل الإلغاء → RideError',
      build: () {
        repo.cancelRideResult = Result.failure(const UnknownFailure('خطأ'));
        return buildCubit();
      },
      act: (cubit) => cubit.cancelRide('ride-1'),
      expect: () => [isA<RideError>()],
    );
  });

  test('close يلغي جميع الاشتراكات بدون أخطاء', () async {
    final cubit = buildCubit();
    cubit.listenToRideStatus('ride-1');
    await cubit.close();
  });
}
