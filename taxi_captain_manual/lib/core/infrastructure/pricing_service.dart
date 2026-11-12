import 'package:cloud_firestore/cloud_firestore.dart';

/// خدمة الأسعار — تقرأ إعدادات الأسعار من Firestore
class PricingService {
  final FirebaseFirestore _firestore;

  PricingService(this._firestore);

  /// جلب إعدادات الأسعار
  Future<PricingSettings> getPricing() async {
    try {
      final doc = await _firestore.collection('settings').doc('pricing').get();
      if (doc.exists) {
        final data = doc.data()!;
        return PricingSettings(
          pricePerKm: (data['pricePerKm'] ?? data['defaultPricePerKm'] ?? 500.0)
              .toDouble(),
          minimumFare: (data['minimumFare'] ?? 500.0).toDouble(),
          commissionPercentage: (data['commissionPercentage'] ?? 10.0)
              .toDouble(),
        );
      }
    } catch (_) {}
    return const PricingSettings();
  }
}

/// كائن إعدادات الأسعار
class PricingSettings {
  final double pricePerKm;
  final double minimumFare;
  final double commissionPercentage;

  const PricingSettings({
    this.pricePerKm = 500.0,
    this.minimumFare = 500.0,
    this.commissionPercentage = 10.0,
  });
}
