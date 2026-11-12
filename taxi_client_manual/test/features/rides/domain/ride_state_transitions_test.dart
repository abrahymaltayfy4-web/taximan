import 'package:flutter_test/flutter_test.dart';

/// ═══════════════════════════════════════════
/// تحولات حالة الرحلة المسموحة
/// يفشل إذا تم الانتقال لحالة غير مسموحة
/// ═══════════════════════════════════════════

/// التحولات المسموحة لكل حالة
const Map<String, List<String>> allowedTransitions = {
  'pending': ['accepted', 'cancelled'],
  'accepted': ['driver_arrived', 'cancelled'],
  'driver_arrived': ['started', 'cancelled'],
  'started': ['completed'],
  'completed': [], // حالة نهائية
  'cancelled': [], // حالة نهائية
};

const allStatuses = [
  'pending',
  'accepted',
  'driver_arrived',
  'started',
  'completed',
  'cancelled',
];

bool isValidTransition(String from, String to) {
  return allowedTransitions[from]?.contains(to) ?? false;
}

void main() {
  group('🔒 Ride State Transitions', () {
    test('pending → accepted مسموح', () {
      expect(isValidTransition('pending', 'accepted'), isTrue);
    });

    test('pending → cancelled مسموح', () {
      expect(isValidTransition('pending', 'cancelled'), isTrue);
    });

    test('pending → completed ممنوع', () {
      expect(isValidTransition('pending', 'completed'), isFalse);
    });

    test('pending → started ممنوع', () {
      expect(isValidTransition('pending', 'started'), isFalse);
    });

    test('pending → driver_arrived ممنوع', () {
      expect(isValidTransition('pending', 'driver_arrived'), isFalse);
    });

    test('accepted → driver_arrived مسموح', () {
      expect(isValidTransition('accepted', 'driver_arrived'), isTrue);
    });

    test('accepted → cancelled مسموح', () {
      expect(isValidTransition('accepted', 'cancelled'), isTrue);
    });

    test('accepted → completed ممنوع', () {
      expect(isValidTransition('accepted', 'completed'), isFalse);
    });

    test('accepted → pending ممنوع (لا رجوع)', () {
      expect(isValidTransition('accepted', 'pending'), isFalse);
    });

    test('driver_arrived → started مسموح', () {
      expect(isValidTransition('driver_arrived', 'started'), isTrue);
    });

    test('driver_arrived → completed ممنوع (يجب بدء أولاً)', () {
      expect(isValidTransition('driver_arrived', 'completed'), isFalse);
    });

    test('started → completed مسموح', () {
      expect(isValidTransition('started', 'completed'), isTrue);
    });

    test('started → cancelled ممنوع (رحلة بدأت)', () {
      expect(isValidTransition('started', 'cancelled'), isFalse);
    });

    test('completed هي حالة نهائية — لا تحول منها', () {
      for (final to in allStatuses) {
        expect(
          isValidTransition('completed', to),
          isFalse,
          reason: 'completed → $to يجب أن يكون ممنوع',
        );
      }
    });

    test('cancelled هي حالة نهائية — لا تحول منها', () {
      for (final to in allStatuses) {
        expect(
          isValidTransition('cancelled', to),
          isFalse,
          reason: 'cancelled → $to يجب أن يكون ممنوع',
        );
      }
    });

    test('لا يمكن الانتقال لحالة غير معرفة', () {
      expect(isValidTransition('pending', 'xyz'), isFalse);
      expect(isValidTransition('xyz', 'pending'), isFalse);
    });
  });

  group('🔒 منع القبول المزدوج', () {
    test('رحلة accepted لا يمكن أن تصبح accepted مرة أخرى', () {
      expect(isValidTransition('accepted', 'accepted'), isFalse);
    });

    test('رحلة pending يمكن قبولها مرة واحدة فقط', () {
      // أول قبول مسموح
      expect(isValidTransition('pending', 'accepted'), isTrue);
      // بعد القبول لا يمكن إعادة القبول
      expect(isValidTransition('accepted', 'accepted'), isFalse);
    });

    test('كل حالة وسطى لا يمكن العودة لـ pending', () {
      for (final status in ['accepted', 'driver_arrived', 'started']) {
        expect(
          isValidTransition(status, 'pending'),
          isFalse,
          reason: '$status → pending يجب أن يكون ممنوع',
        );
      }
    });
  });

  group('🔒 سلامة تدفق الرحلة الكامل', () {
    test(
      'التدفق الطبيعي: pending → accepted → driver_arrived → started → completed',
      () {
        final flow = [
          'pending',
          'accepted',
          'driver_arrived',
          'started',
          'completed',
        ];
        for (int i = 0; i < flow.length - 1; i++) {
          expect(
            isValidTransition(flow[i], flow[i + 1]),
            isTrue,
            reason: '${flow[i]} → ${flow[i + 1]} يجب أن يكون مسموح',
          );
        }
      },
    );

    test('الإلغاء ممكن من pending, accepted, driver_arrived فقط', () {
      expect(isValidTransition('pending', 'cancelled'), isTrue);
      expect(isValidTransition('accepted', 'cancelled'), isTrue);
      expect(isValidTransition('driver_arrived', 'cancelled'), isTrue);
      expect(isValidTransition('started', 'cancelled'), isFalse);
    });
  });
}
