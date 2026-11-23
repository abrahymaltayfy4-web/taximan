import '../entities/place_suggestion.dart';
import '../entities/place_details.dart';

/// عقد المستودع — يُعرّف العمليات المطلوبة للبحث عن الأماكن
/// الـ Data Layer تُنفّذ هذا العقد
abstract class PlaceSearchRepository {
  /// البحث عن أماكن بناءً على نص الإدخال
  /// [query] — النص الذي يبحث عنه المستخدم
  /// [sessionToken] — رمز الجلسة لتجميع الطلبات (تقليل التكلفة)
  /// [location] — الموقع الحالي لتحسين النتائج (اختياري)
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    String? sessionToken,
    double? latitude,
    double? longitude,
  });

  /// جلب تفاصيل مكان محدد باستخدام معرّفه
  /// [placeId] — معرّف المكان من Google
  /// [sessionToken] — رمز الجلسة (يُنهي الجلسة بعد الاستدعاء)
  Future<PlaceDetails> getPlaceDetails({
    required String placeId,
    String? sessionToken,
  });
}
