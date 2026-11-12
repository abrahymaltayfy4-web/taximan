import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_captain_manual/core/shared/pricing_config.dart';

void main() {
  group('PricingConfig.calculateFare', () {
    const config = PricingConfig(
      baseFare: 100,
      pricePerKm: 500,
      minimumFare: 500,
      commissionPercentage: 10,
    );

    test('المسافة 0 كم → baseFare + minimumFare', () {
      expect(config.calculateFare(0), equals(600)); // 100 + max(500, 0) = 600
    });

    test('المسافة 0.5 كم → baseFare + minimumFare (أقل من الحد الأدنى)', () {
      expect(
        config.calculateFare(0.5),
        equals(600),
      ); // 100 + max(500, 250) = 600
    });

    test('المسافة 1.0 كم → baseFare + minimumFare (يساوي الحد الأدنى)', () {
      expect(
        config.calculateFare(1.0),
        equals(600),
      ); // 100 + max(500, 500) = 600
    });

    test('المسافة 2.0 كم → baseFare + distanceFare (أكبر من الحد الأدنى)', () {
      expect(
        config.calculateFare(2.0),
        equals(1100),
      ); // 100 + max(500, 1000) = 1100
    });

    test('المسافة 10 كم → baseFare + distanceFare', () {
      expect(
        config.calculateFare(10.0),
        equals(5100),
      ); // 100 + max(500, 5000) = 5100
    });

    test('بدون baseFare → يساوي max(minimumFare, distance * pricePerKm)', () {
      const noBase = PricingConfig(
        baseFare: 0,
        pricePerKm: 500,
        minimumFare: 500,
      );
      expect(noBase.calculateFare(0.5), equals(500)); // 0 + max(500, 250) = 500
      expect(
        noBase.calculateFare(2.0),
        equals(1000),
      ); // 0 + max(500, 1000) = 1000
    });
  });

  group('PricingConfig.calculateCommission', () {
    const config = PricingConfig(commissionPercentage: 10);

    test('عمولة 10% من 1000 = 100', () {
      expect(config.calculateCommission(1000), equals(100));
    });

    test('عمولة 10% من 500 = 50', () {
      expect(config.calculateCommission(500), equals(50));
    });

    test('عمولة 0% = 0', () {
      const zero = PricingConfig(commissionPercentage: 0);
      expect(zero.calculateCommission(1000), equals(0));
    });
  });

  group('PricingConfig.fromMap', () {
    test('يقرأ كل الحقول', () {
      final config = PricingConfig.fromMap({
        'baseFare': 100,
        'pricePerKm': 600,
        'minimumFare': 400,
        'commissionPercentage': 15,
      });
      expect(config.baseFare, equals(100));
      expect(config.pricePerKm, equals(600));
      expect(config.minimumFare, equals(400));
      expect(config.commissionPercentage, equals(15));
    });

    test('يستخدم القيم الافتراضية عند عدم وجود البيانات', () {
      final config = PricingConfig.fromMap({});
      expect(config.baseFare, equals(0));
      expect(config.pricePerKm, equals(500));
      expect(config.minimumFare, equals(500));
      expect(config.commissionPercentage, equals(10));
    });

    test('يقرأ defaultPricePerKm كـ fallback', () {
      final config = PricingConfig.fromMap({'defaultPricePerKm': 700});
      expect(config.pricePerKm, equals(700));
    });

    test('pricePerKm أولوية أعلى من defaultPricePerKm', () {
      final config = PricingConfig.fromMap({
        'pricePerKm': 800,
        'defaultPricePerKm': 700,
      });
      expect(config.pricePerKm, equals(800));
    });
  });
}
