import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_captain_manual/core/shared/ride_status.dart';

void main() {
  group('RideStatus.fromString', () {
    test('يحول كل القيم الصحيحة', () {
      expect(RideStatus.fromString('pending'), RideStatus.pending);
      expect(RideStatus.fromString('accepted'), RideStatus.accepted);
      expect(RideStatus.fromString('driver_arrived'), RideStatus.driverArrived);
      expect(RideStatus.fromString('started'), RideStatus.started);
      expect(RideStatus.fromString('completed'), RideStatus.completed);
      expect(RideStatus.fromString('cancelled'), RideStatus.cancelled);
    });

    test('قيمة غير معروفة → pending', () {
      expect(RideStatus.fromString('xyz'), RideStatus.pending);
      expect(RideStatus.fromString(null), RideStatus.pending);
    });
  });

  group('RideStatus.allowedTransitions', () {
    test('pending → accepted أو cancelled فقط', () {
      expect(RideStatus.pending.allowedTransitions, [
        RideStatus.accepted,
        RideStatus.cancelled,
      ]);
    });

    test('accepted → driver_arrived أو cancelled فقط', () {
      expect(RideStatus.accepted.allowedTransitions, [
        RideStatus.driverArrived,
        RideStatus.cancelled,
      ]);
    });

    test('driver_arrived → started فقط', () {
      expect(RideStatus.driverArrived.allowedTransitions, [RideStatus.started]);
    });

    test('started → completed فقط', () {
      expect(RideStatus.started.allowedTransitions, [RideStatus.completed]);
    });

    test('completed → لا انتقالات', () {
      expect(RideStatus.completed.allowedTransitions, isEmpty);
    });

    test('cancelled → لا انتقالات', () {
      expect(RideStatus.cancelled.allowedTransitions, isEmpty);
    });
  });

  group('RideStatus.canTransitionTo', () {
    test('pending → accepted = true', () {
      expect(RideStatus.pending.canTransitionTo(RideStatus.accepted), true);
    });

    test('pending → completed = false (لا يجوز القفز)', () {
      expect(RideStatus.pending.canTransitionTo(RideStatus.completed), false);
    });

    test('started → cancelled = false (لا إلغاء بعد البدء)', () {
      expect(RideStatus.started.canTransitionTo(RideStatus.cancelled), false);
    });
  });

  group('RideStatus.isActive', () {
    test('الحالات النشطة', () {
      expect(RideStatus.pending.isActive, true);
      expect(RideStatus.accepted.isActive, true);
      expect(RideStatus.driverArrived.isActive, true);
      expect(RideStatus.started.isActive, true);
    });

    test('الحالات المنتهية', () {
      expect(RideStatus.completed.isActive, false);
      expect(RideStatus.cancelled.isActive, false);
    });
  });
}
