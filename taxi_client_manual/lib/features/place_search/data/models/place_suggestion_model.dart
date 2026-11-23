import '../../domain/entities/place_suggestion.dart';

/// نموذج اقتراح المكان — يحوّل بيانات JSON من Google Places API
/// إلى كيان [PlaceSuggestion] في الـ Domain Layer
class PlaceSuggestionModel extends PlaceSuggestion {
  const PlaceSuggestionModel({
    required super.placeId,
    required super.mainText,
    required super.secondaryText,
    required super.fullDescription,
  });

  /// تحويل JSON من Autocomplete API إلى نموذج
  factory PlaceSuggestionModel.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};

    return PlaceSuggestionModel(
      placeId: json['place_id'] as String? ?? '',
      mainText:
          structuredFormatting['main_text'] as String? ??
          json['description'] as String? ??
          '',
      secondaryText:
          structuredFormatting['secondary_text'] as String? ?? '',
      fullDescription: json['description'] as String? ?? '',
    );
  }
}
