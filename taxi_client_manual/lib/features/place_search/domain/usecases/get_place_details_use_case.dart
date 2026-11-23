import '../entities/place_details.dart';
import '../repositories/place_search_repository.dart';

/// حالة استخدام جلب تفاصيل مكان محدد
/// Single Responsibility: جلب التفاصيل فقط (الإحداثيات + العنوان)
class GetPlaceDetailsUseCase {
  final PlaceSearchRepository _repository;

  const GetPlaceDetailsUseCase(this._repository);

  /// تنفيذ جلب التفاصيل
  Future<PlaceDetails> call({
    required String placeId,
    String? sessionToken,
  }) {
    return _repository.getPlaceDetails(
      placeId: placeId,
      sessionToken: sessionToken,
    );
  }
}
