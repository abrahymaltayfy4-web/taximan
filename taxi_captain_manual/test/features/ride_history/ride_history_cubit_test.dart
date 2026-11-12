import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:taxi_captain_manual/features/ride_history/cubit/ride_history_cubit.dart';
import 'package:taxi_captain_manual/features/ride_history/domain/repositories/ride_history_repository_contract.dart';
import 'package:taxi_captain_manual/features/ride_history/domain/usecases/load_ride_history_use_case.dart';
import 'package:taxi_captain_manual/features/rides/domain/entities/ride_entity.dart';
import 'package:taxi_captain_manual/features/rides/domain/entities/location_entity.dart';

/// ═══════════════════════════════════════════
/// Fake RideHistoryRepository — بدون Firebase
/// ═══════════════════════════════════════════
class FakeRideHistoryRepository implements RideHistoryRepositoryContract {
  List<RideEntity> ridesToReturn = [];
  bool shouldThrow = false;
  String? lastFilterType;

  @override
  Future<List<RideEntity>> getCompletedRides(String filterType) async {
    lastFilterType = filterType;
    if (shouldThrow) throw Exception('Network error');
    return ridesToReturn;
  }
}

RideEntity _fakeRide({
  String id = 'r1',
  double fare = 1500,
  double distance = 3.0,
}) {
  return RideEntity(
    rideId: id,
    customerId: 'c1',
    customerName: 'عميل',
    customerPhone: '0512345678',
    driverId: 'fake-uid',
    driverName: 'كابتن',
    driverPhone: '0598765432',
    driverCarModel: 'Toyota',
    driverCarPlate: 'ABC',
    pickupLocation: const LocationEntity(latitude: 24.7, longitude: 46.7),
    pickupAddress: 'المطار',
    destinationLocation: const LocationEntity(latitude: 24.8, longitude: 46.8),
    destinationAddress: 'الفندق',
    status: 'completed',
    fare: fare,
    distanceKm: distance,
    createdAt: DateTime.now(),
  );
}

void main() {
  late FakeRideHistoryRepository repo;
  late LoadRideHistoryUseCase loadRideHistory;

  setUp(() {
    repo = FakeRideHistoryRepository();
    loadRideHistory = LoadRideHistoryUseCase(repo);
  });

  group('🔒 RideHistoryCubit مع Fake', () {
    blocTest<RideHistoryCubit, RideHistoryState>(
      'تحميل رحلات ناجح — اليوم',
      build: () {
        repo.ridesToReturn = [
          _fakeRide(fare: 1500),
          _fakeRide(id: 'r2', fare: 2000),
        ];
        return RideHistoryCubit(loadRideHistory);
      },
      act: (cubit) => cubit.loadRideHistory('اليوم'),
      expect: () => [
        isA<RideHistoryLoading>(),
        isA<RideHistoryLoaded>()
            .having((s) => s.totalRides, 'totalRides', 2)
            .having((s) => s.totalFare, 'totalFare', 3500.0)
            .having((s) => s.filterType, 'filter', 'اليوم'),
      ],
      verify: (_) {
        expect(repo.lastFilterType, 'اليوم');
      },
    );

    blocTest<RideHistoryCubit, RideHistoryState>(
      'قائمة فارغة → Loaded مع 0',
      build: () {
        repo.ridesToReturn = [];
        return RideHistoryCubit(loadRideHistory);
      },
      act: (cubit) => cubit.loadRideHistory('الأسبوع'),
      expect: () => [
        isA<RideHistoryLoading>(),
        isA<RideHistoryLoaded>()
            .having((s) => s.totalRides, 'total', 0)
            .having((s) => s.totalFare, 'fare', 0.0),
      ],
    );

    blocTest<RideHistoryCubit, RideHistoryState>(
      'خطأ شبكة → RideHistoryError',
      build: () {
        repo.shouldThrow = true;
        return RideHistoryCubit(loadRideHistory);
      },
      act: (cubit) => cubit.loadRideHistory('الشهر'),
      expect: () => [isA<RideHistoryLoading>(), isA<RideHistoryError>()],
    );

    blocTest<RideHistoryCubit, RideHistoryState>(
      'تغيير الفلتر يحدّث البيانات',
      build: () {
        repo.ridesToReturn = [_fakeRide()];
        return RideHistoryCubit(loadRideHistory);
      },
      act: (cubit) async {
        await cubit.loadRideHistory('اليوم');
        repo.ridesToReturn = [_fakeRide(), _fakeRide(id: 'r2')];
        await cubit.loadRideHistory('الشهر');
      },
      expect: () => [
        isA<RideHistoryLoading>(),
        isA<RideHistoryLoaded>().having((s) => s.totalRides, 'first', 1),
        isA<RideHistoryLoading>(),
        isA<RideHistoryLoaded>().having((s) => s.totalRides, 'second', 2),
      ],
    );
  });

  group('🔒 حسابات مجاميع الرحلات', () {
    test('totalFare = مجموع فواتير كل الرحلات', () {
      final rides = [
        _fakeRide(fare: 1000),
        _fakeRide(id: 'r2', fare: 2500),
        _fakeRide(id: 'r3', fare: 750),
      ];
      final total = rides.fold<double>(0, (acc, r) => acc + r.fare);
      expect(total, 4250.0);
    });

    test('totalDistance = مجموع المسافات', () {
      final rides = [
        _fakeRide(distance: 2.0),
        _fakeRide(id: 'r2', distance: 5.5),
      ];
      final total = rides.fold<double>(0, (acc, r) => acc + r.distanceKm);
      expect(total, 7.5);
    });
  });
}
