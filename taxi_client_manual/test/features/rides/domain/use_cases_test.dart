import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_client_manual/core/error/result.dart';
import 'package:taxi_client_manual/features/rides/domain/customer_ride_repository.dart';
import 'package:taxi_client_manual/features/rides/domain/ride_entity.dart';
import 'package:taxi_client_manual/features/rides/domain/location_entity.dart';
import 'package:taxi_client_manual/features/rides/domain/request_ride_use_case.dart';
import 'package:taxi_client_manual/features/rides/domain/watch_active_ride_use_case.dart';
import 'package:taxi_client_manual/features/rides/domain/cancel_ride_use_case.dart';
import 'package:taxi_client_manual/features/rides/domain/load_ride_history_use_case.dart';

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
  }) async {
    return requestRideResult ?? Result.failure(const UnknownFailure('not set'));
  }

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
// بيانات اختبار
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

// ═══════════════════════════════════════════
// اختبارات
// ═══════════════════════════════════════════
void main() {
  late FakeRideRepository repo;

  setUp(() => repo = FakeRideRepository());
  tearDown(() => repo.dispose());

  group('RequestRideUseCase', () {
    test('نجاح — يعيد ride ID', () async {
      repo.requestRideResult = Result.success('ride-123');
      final useCase = RequestRideUseCase(repo);

      final result = await useCase(
        pickupLocation: _pickup,
        pickupAddress: 'test',
        destinationLocation: _dest,
        destinationAddress: 'test',
        distanceKm: 2.0,
      );

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'ride-123');
    });

    test('فشل — حساب محظور', () async {
      repo.requestRideResult = Result.failure(
        const BlockedAccountFailure('محظور'),
      );
      final useCase = RequestRideUseCase(repo);

      final result = await useCase(
        pickupLocation: _pickup,
        pickupAddress: 'test',
        destinationLocation: _dest,
        destinationAddress: 'test',
        distanceKm: 2.0,
      );

      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<BlockedAccountFailure>());
    });
  });

  group('WatchActiveRideUseCase', () {
    test('يعيد stream من RideEntity', () async {
      final useCase = WatchActiveRideUseCase(repo);
      final ride = _makeRide(status: 'accepted', driverId: 'd-1');

      final future = useCase('ride-1').first;
      repo.rideController.add(Result.success(ride));
      final result = await future;

      expect(result, isA<Success<RideEntity>>());
      expect((result as Success<RideEntity>).data.status, 'accepted');
    });

    test('watchDriverLocation يعيد stream', () async {
      final useCase = WatchActiveRideUseCase(repo);
      const loc = LocationEntity(latitude: 24.7, longitude: 46.7);

      final future = useCase.watchDriverLocation('d-1').first;
      repo.driverLocationController.add(Result.success(loc));
      final result = await future;

      expect(result, isA<Success<LocationEntity>>());
      expect((result as Success<LocationEntity>).data.latitude, 24.7);
    });
  });

  group('CancelRideUseCase', () {
    test('نجاح', () async {
      repo.cancelRideResult = Result.success(null);
      final useCase = CancelRideUseCase(repo);

      final result = await useCase('ride-1');
      expect(result, isA<Success<void>>());
    });

    test('فشل', () async {
      repo.cancelRideResult = Result.failure(const UnknownFailure('خطأ'));
      final useCase = CancelRideUseCase(repo);

      final result = await useCase('ride-1');
      expect(result, isA<Err<void>>());
    });
  });

  group('LoadRideHistoryUseCase', () {
    test('يعيد قائمة رحلات', () async {
      repo.loadHistoryResult = Result.success([
        _makeRide(status: 'completed'),
        _makeRide(status: 'cancelled'),
      ]);
      final useCase = LoadRideHistoryUseCase(repo);

      final result = await useCase();
      expect(result, isA<Success<List<RideEntity>>>());
      expect((result as Success<List<RideEntity>>).data.length, 2);
    });
  });
}
