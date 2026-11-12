import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_captain_manual/core/shared/account_status.dart';

void main() {
  group('AccountStatus.fromString', () {
    test('يحول كل القيم الصحيحة', () {
      expect(AccountStatus.fromString('active'), AccountStatus.active);
      expect(AccountStatus.fromString('pending'), AccountStatus.pending);
      expect(AccountStatus.fromString('rejected'), AccountStatus.rejected);
      expect(AccountStatus.fromString('suspended'), AccountStatus.suspended);
      expect(AccountStatus.fromString('blocked'), AccountStatus.blocked);
      expect(AccountStatus.fromString('disabled'), AccountStatus.disabled);
    });

    test('قيمة غير معروفة → active (افتراضي)', () {
      expect(AccountStatus.fromString('unknown'), AccountStatus.active);
      expect(AccountStatus.fromString(null), AccountStatus.active);
      expect(AccountStatus.fromString(''), AccountStatus.active);
    });
  });

  group('AccountStatus.canLogin', () {
    test('active و suspended يمكنهم الدخول', () {
      expect(AccountStatus.active.canLogin, true);
      expect(AccountStatus.suspended.canLogin, true);
    });

    test('pending و rejected و blocked و disabled لا يمكنهم الدخول', () {
      expect(AccountStatus.pending.canLogin, false);
      expect(AccountStatus.rejected.canLogin, false);
      expect(AccountStatus.blocked.canLogin, false);
      expect(AccountStatus.disabled.canLogin, false);
    });
  });

  group('AccountStatus.canUseRides', () {
    test('فقط active يمكنه استخدام الرحلات', () {
      expect(AccountStatus.active.canUseRides, true);
      expect(AccountStatus.suspended.canUseRides, false);
      expect(AccountStatus.blocked.canUseRides, false);
    });
  });

  group('AccountStatus.userMessage', () {
    test('active لا رسالة', () {
      expect(AccountStatus.active.userMessage, isEmpty);
    });

    test('blocked رسالة واضحة', () {
      expect(AccountStatus.blocked.userMessage, contains('محظور'));
    });

    test('pending رسالة مراجعة', () {
      expect(AccountStatus.pending.userMessage, contains('قيد المراجعة'));
    });
  });
}
