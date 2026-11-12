/// إعدادات التسعير — مصدر الحقيقة الوحيد للمعادلة (Domain خالص).
/// التحويل من/إلى Firestore يتم في طبقة Data (PricingMapper).
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

  /// أجرة المسافة فقط: `max(minimumFare, distanceKm × pricePerKm)`
  double calculateDistanceFare(double distanceKm) {
    final distanceFare = distanceKm * pricePerKm;
    return distanceFare < minimumFare ? minimumFare : distanceFare;
  }

  /// المعادلة الموحدة: `fare = baseFare + max(minimumFare, distanceKm × pricePerKm)`
  double calculateFare(double distanceKm) {
    return baseFare + calculateDistanceFare(distanceKm);
  }

  /// حساب العمولة من الأجرة النهائية
  double calculateCommission(double fare) {
    return fare * commissionPercentage / 100;
  }

  @override
  String toString() =>
      'PricingConfig(base=$baseFare, perKm=$pricePerKm, min=$minimumFare, commission=$commissionPercentage%)';
}
