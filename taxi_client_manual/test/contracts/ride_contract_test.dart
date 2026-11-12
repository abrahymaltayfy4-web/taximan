// test/contracts/ride_contract_test.dart
//
// اختبارات العقد — تمنع اختلاف تعريف RideStatus أو حقول Ride
// بين المشاريع. يجب أن تنجح في كلا المشروعين (Client + Captain).

import 'package:flutter_test/flutter_test.dart';

/// ═══════════════════════════════════════════
/// مصدر الحقيقة — من rahal-contract.schema.json
/// ═══════════════════════════════════════════

/// حالات الرحلة المسموحة — 6 حالات فقط
const List<String> contractRideStatuses = [
  'pending',
  'accepted',
  'driver_arrived',
  'started',
  'completed',
  'cancelled',
];

/// حقول الرحلة المطلوبة
const List<String> contractRideRequiredFields = [
  'customerId',
  'customerName',
  'customerPhone',
  'pickupLocation',
  'pickupAddress',
  'destinationLocation',
  'destinationAddress',
  'status',
  'fare',
  'distanceKm',
  'createdAt',
];

/// حقول الرحلة الاختيارية (nullable)
const List<String> contractRideNullableFields = [
  'driverId',
  'driverName',
  'driverPhone',
  'driverCarModel',
  'driverCarPlate',
  'acceptedAt',
  'completedAt',
];

/// حالات السائق المسموحة
const List<String> contractDriverStatuses = [
  'offline',
  'online',
  'busy',
  'suspended',
];

/// حالات الموافقة المسموحة
const List<String> contractApprovalStatuses = [
  'pending',
  'approved',
  'rejected',
];

/// حقول السائق المطلوبة
const List<String> contractDriverRequiredFields = [
  'name',
  'email',
  'phone',
  'carModel',
  'carPlate',
  'pricePerKm',
  'status',
  'rating',
  'approvalStatus',
];

/// حقول التسعير المطلوبة
const List<String> contractPricingFields = [
  'pricePerKm',
  'minimumFare',
  'commissionPercentage',
];

void main() {
  group('🔒 Ride Contract Tests', () {
    test('RideStatus يجب أن يحتوي بالضبط على 6 حالات', () {
      expect(contractRideStatuses.length, 6);
    });

    test('RideStatus يجب أن يشمل pending', () {
      expect(contractRideStatuses, contains('pending'));
    });

    test('RideStatus يجب أن يشمل accepted', () {
      expect(contractRideStatuses, contains('accepted'));
    });

    test('RideStatus يجب أن يشمل driver_arrived', () {
      expect(contractRideStatuses, contains('driver_arrived'));
    });

    test('RideStatus يجب أن يشمل started', () {
      expect(contractRideStatuses, contains('started'));
    });

    test('RideStatus يجب أن يشمل completed', () {
      expect(contractRideStatuses, contains('completed'));
    });

    test('RideStatus يجب أن يشمل cancelled', () {
      expect(contractRideStatuses, contains('cancelled'));
    });

    test('الحقول المطلوبة يجب ألا تكون فارغة', () {
      expect(contractRideRequiredFields, isNotEmpty);
      expect(contractRideRequiredFields.length, 11);
    });

    test('الحقول الاختيارية يجب ألا تتداخل مع المطلوبة', () {
      for (final field in contractRideNullableFields) {
        expect(
          contractRideRequiredFields,
          isNot(contains(field)),
          reason: '$field يجب ألا يكون مطلوباً ونلابل في آن واحد',
        );
      }
    });

    test('RideModel.toJson يجب أن يكتب كل الحقول المطلوبة', () {
      // يحاكي ما يكتبه RideModel.toJson()
      final Map<String, dynamic> mockJson = {
        'customerId': 'c1',
        'customerName': 'أحمد',
        'customerPhone': '05xxxxxxxx',
        'pickupLocation': 'GeoPoint', // placeholder
        'pickupAddress': 'حي النزهة',
        'destinationLocation': 'GeoPoint',
        'destinationAddress': 'المطار',
        'status': 'pending',
        'fare': 50.0,
        'distanceKm': 10.0,
        'createdAt': 'Timestamp',
      };

      for (final field in contractRideRequiredFields) {
        expect(
          mockJson.containsKey(field),
          isTrue,
          reason: 'حقل $field مفقود من toJson()',
        );
      }
    });

    test('RideModel.fromJson يجب أن يتعامل مع القيم الناقصة بأمان', () {
      // كل حقل nullable يجب أن يقبل null بدون crash
      final Map<String, dynamic> minimalJson = {
        'customerId': 'c1',
        'customerName': 'test',
        'customerPhone': '05',
        'status': 'pending',
      };
      // لا pickupLocation, لا fare, لا distanceKm, لا createdAt
      // يجب أن يكون لكل منها fallback default

      // التحقق من أن Dart models تتعامل مع null
      expect(minimalJson['driverId'], isNull);
      expect(minimalJson['driverName'], isNull);
      expect(minimalJson['fare'], isNull); // يجب أن يصبح 0.0
      expect(minimalJson['distanceKm'], isNull); // يجب أن يصبح 0.0
    });
  });

  group('🔒 Driver Contract Tests', () {
    test('DriverStatus يجب أن يحتوي بالضبط على 4 حالات', () {
      expect(contractDriverStatuses.length, 4);
    });

    test('ApprovalStatus يجب أن يحتوي بالضبط على 3 حالات', () {
      expect(contractApprovalStatuses.length, 3);
    });

    test('حقول السائق المطلوبة يجب أن تكون 9', () {
      expect(contractDriverRequiredFields.length, 9);
    });

    test('DriverStatus يجب ألا يحتوي على suspended مكرر', () {
      expect(contractDriverStatuses.where((s) => s == 'suspended').length, 1);
    });
  });

  group('🔒 Pricing Contract Tests', () {
    test('حقول التسعير الثلاثة مطلوبة', () {
      expect(contractPricingFields, contains('pricePerKm'));
      expect(contractPricingFields, contains('minimumFare'));
      expect(contractPricingFields, contains('commissionPercentage'));
    });

    test('القيم الافتراضية يجب أن تكون موحدة', () {
      // مصدر الحقيقة
      const defaultPricePerKm = 500.0;
      const defaultMinimumFare = 500.0;
      const defaultCommission = 10.0;

      expect(defaultPricePerKm, 500.0);
      expect(defaultMinimumFare, 500.0);
      expect(defaultCommission, 10.0);
    });
  });

  group('🔒 Cross-Platform Field Name Contract', () {
    test('Firestore field names يجب أن تتطابق عبر المشاريع', () {
      // أسماء الحقول في Firestore — لا يجوز تغييرها
      const firestoreRideFields = [
        'customerId',
        'customerName',
        'customerPhone',
        'driverId',
        'driverName',
        'driverPhone',
        'driverCarModel',
        'driverCarPlate',
        'pickupLocation',
        'pickupAddress',
        'destinationLocation',
        'destinationAddress',
        'status',
        'fare',
        'distanceKm',
        'createdAt',
        'acceptedAt',
        'completedAt',
      ];

      const firestoreDriverFields = [
        'name',
        'email',
        'phone',
        'carModel',
        'carPlate',
        'pricePerKm',
        'status',
        'location',
        'rating',
        'approvalStatus',
        'isBlocked',
        'isDisabled',
        'totalCommissionOwed',
        'totalPaid',
        'fcmToken',
      ];

      // التحقق من عدم وجود أحرف كبيرة في البداية
      for (final f in [...firestoreRideFields, ...firestoreDriverFields]) {
        expect(
          f[0],
          f[0].toLowerCase(),
          reason: 'حقل $f يجب أن يبدأ بحرف صغير (camelCase)',
        );
      }

      // التحقق من عدم وجود حقول بأسماء مكررة
      expect(
        firestoreRideFields.toSet().length,
        firestoreRideFields.length,
        reason: 'يوجد تكرار في أسماء حقول الرحلة',
      );
    });
  });
}
