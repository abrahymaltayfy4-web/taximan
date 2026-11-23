import '../../domain/entities/place_details.dart';

/// نموذج تفاصيل المكان — يحوّل بيانات JSON من Place Details API
/// إلى كيان [PlaceDetails] في الـ Domain Layer
class PlaceDetailsModel extends PlaceDetails {
  const PlaceDetailsModel({
    required super.placeId,
    required super.name,
    required super.formattedAddress,
    required super.latitude,
    required super.longitude,
  });

  /// تحويل JSON من Place Details API إلى نموذج
  factory PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? json;
    final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};

    return PlaceDetailsModel(
      placeId: result['place_id'] as String? ?? '',
      name: result['name'] as String? ?? '',
      formattedAddress: result['formatted_address'] as String? ?? '',
      latitude: (location['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (location['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
