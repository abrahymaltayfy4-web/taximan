import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/search_places_use_case.dart';
import '../../domain/usecases/get_place_details_use_case.dart';
import 'place_search_state.dart';

/// Cubit يدير حالة البحث عن الأماكن
/// يستخدم debounce لتقليل الاستدعاءات أثناء الكتابة
/// ويستخدم sessionToken لتجميع الطلبات (تقليل تكلفة Google API)
class PlaceSearchCubit extends Cubit<PlaceSearchState> {
  final SearchPlacesUseCase _searchPlaces;
  final GetPlaceDetailsUseCase _getPlaceDetails;

  /// مؤقت debounce — ينتظر 400ms بعد آخر حرف قبل البحث
  Timer? _debounceTimer;

  /// رمز الجلسة — يربط مجموعة بحث + تفاصيل بجلسة واحدة
  String _sessionToken;

  /// الموقع الحالي لتحسين نتائج البحث
  double? _currentLatitude;
  double? _currentLongitude;

  PlaceSearchCubit({
    required SearchPlacesUseCase searchPlaces,
    required GetPlaceDetailsUseCase getPlaceDetails,
  })  : _searchPlaces = searchPlaces,
        _getPlaceDetails = getPlaceDetails,
        _sessionToken = DateTime.now().millisecondsSinceEpoch.toString(),
        super(const PlaceSearchInitial());

  /// تعيين الموقع الحالي لتحسين نتائج البحث (Bias)
  void setCurrentLocation(double latitude, double longitude) {
    _currentLatitude = latitude;
    _currentLongitude = longitude;
  }

  /// البحث مع debounce — يُستدعى عند كل تغيير في حقل البحث
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      emit(const PlaceSearchInitial());
      return;
    }

    if (trimmed.length < 2) return; // لا تبحث عن حرف واحد

    emit(const PlaceSearchLoading());

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(trimmed);
    });
  }

  /// تنفيذ البحث الفعلي
  Future<void> _performSearch(String query) async {
    try {
      final results = await _searchPlaces(
        query: query,
        sessionToken: _sessionToken,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
      );

      if (isClosed) return;

      if (results.isEmpty) {
        emit(PlaceSearchEmpty(query));
      } else {
        emit(PlaceSearchLoaded(results));
      }
    } catch (e) {
      if (!isClosed) {
        emit(PlaceSearchError(e.toString()));
      }
    }
  }

  /// اختيار مكان من القائمة — يجلب التفاصيل (الإحداثيات)
  Future<void> selectPlace(String placeId) async {
    emit(const PlaceDetailsLoading());

    try {
      final details = await _getPlaceDetails(
        placeId: placeId,
        sessionToken: _sessionToken,
      );

      // تجديد رمز الجلسة بعد اختيار مكان
      _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();

      if (!isClosed) {
        emit(PlaceDetailsLoaded(details));
      }
    } catch (e) {
      if (!isClosed) {
        emit(PlaceDetailsError(e.toString()));
      }
    }
  }

  /// مسح البحث والعودة للحالة الأولية
  void clearSearch() {
    _debounceTimer?.cancel();
    emit(const PlaceSearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
