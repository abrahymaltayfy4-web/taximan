import '../domain/pricing_config.dart';

/// Firestore Map ⇄ PricingConfig
abstract final class PricingMapper {
  static PricingConfig fromMap(Map<String, dynamic> data) {
    return PricingConfig(
      baseFare: (data['baseFare'] ?? 0.0).toDouble(),
      pricePerKm: (data['pricePerKm'] ?? data['defaultPricePerKm'] ?? 500.0)
          .toDouble(),
      minimumFare: (data['minimumFare'] ?? 500.0).toDouble(),
      commissionPercentage: (data['commissionPercentage'] ?? 10.0).toDouble(),
    );
  }
}
