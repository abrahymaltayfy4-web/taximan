import '../entities/place_suggestion.dart';
import '../repositories/place_search_repository.dart';

/// حالة استخدام البحث عن أماكن
/// Single Responsibility: تنفيذ عملية البحث فقط
class SearchPlacesUseCase {
  final PlaceSearchRepository _repository;

  const SearchPlacesUseCase(this._repository);

  /// تنفيذ البحث
  Future<List<PlaceSuggestion>> call({
    required String query,
    String? sessionToken,
    double? latitude,
    double? longitude,
  }) {
    return _repository.searchPlaces(
      query: query,
      sessionToken: sessionToken,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
