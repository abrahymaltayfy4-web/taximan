/// إعدادات التسعير — مصدر الحقيقة الوحيد للمعادلة
class PricingConfig {
  /// رسوم بداية الرحلة (تُضاف دائماً)
  final double baseFare;

  /// سعر الكيلومتر
  final double pricePerKm;

  /// الحد الأدنى لأجرة المسافة (بدون baseFare)
  final double minimumFare;

  /// نسبة العمولة (0-100)
  final double commissionPercentage;

  const PricingConfig({
    this.baseFare = 0.0,
    this.pricePerKm = 500.0,
    this.minimumFare = 500.0,
    this.commissionPercentage = 10.0,
  });

  /// المعادلة الموحدة:
  /// `fare = baseFare + max(minimumFare, distanceKm × pricePerKm)`
  ///
  /// - `baseFare`: رسوم ثابتة تُضاف لكل رحلة
  /// - `minimumFare`: الحد الأدنى لأجرة المسافة فقط
  /// - إذا كانت المسافة × السعر أقل من minimumFare → يُستخدم minimumFare
  double calculateFare(double distanceKm) {
    final distanceFare = distanceKm * pricePerKm;
    final effectiveDistanceFare = distanceFare < minimumFare
        ? minimumFare
        : distanceFare;
    return baseFare + effectiveDistanceFare;
  }

  /// حساب العمولة من الأجرة النهائية
  double calculateCommission(double fare) {
    return fare * commissionPercentage / 100;
  }

  /// إنشاء من بيانات Firestore
  factory PricingConfig.fromMap(Map<String, dynamic> data) {
    return PricingConfig(
      baseFare: (data['baseFare'] ?? 0.0).toDouble(),
      pricePerKm: (data['pricePerKm'] ?? data['defaultPricePerKm'] ?? 500.0)
          .toDouble(),
      minimumFare: (data['minimumFare'] ?? 500.0).toDouble(),
      commissionPercentage: (data['commissionPercentage'] ?? 10.0).toDouble(),
    );
  }

  @override
  String toString() =>
      'PricingConfig(base=$baseFare, perKm=$pricePerKm, min=$minimumFare, commission=$commissionPercentage%)';
}
