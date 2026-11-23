import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_client_manual/features/place_search/domain/entities/place_suggestion.dart';
import 'package:taxi_client_manual/features/place_search/domain/entities/place_details.dart';
import 'package:taxi_client_manual/features/place_search/domain/repositories/place_search_repository.dart';
import 'package:taxi_client_manual/features/place_search/domain/usecases/search_places_use_case.dart';
import 'package:taxi_client_manual/features/place_search/domain/usecases/get_place_details_use_case.dart';

// ═══════════════════════════════════════════
// Fake Repository
// ═══════════════════════════════════════════
class FakePlaceSearchRepository implements PlaceSearchRepository {
  List<PlaceSuggestion>? searchResult;
  PlaceDetails? detailsResult;
  Exception? errorToThrow;

  /// عدد مرات استدعاء كل دالة
  int searchCallCount = 0;
  int detailsCallCount = 0;

  /// آخر معاملات تم تمريرها
  String? lastQuery;
  String? lastSessionToken;
  String? lastPlaceId;

  @override
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    String? sessionToken,
    double? latitude,
    double? longitude,
  }) async {
    searchCallCount++;
    lastQuery = query;
    lastSessionToken = sessionToken;
    if (errorToThrow != null) throw errorToThrow!;
    return searchResult ?? [];
  }

  @override
  Future<PlaceDetails> getPlaceDetails({
    required String placeId,
    String? sessionToken,
  }) async {
    detailsCallCount++;
    lastPlaceId = placeId;
    lastSessionToken = sessionToken;
    if (errorToThrow != null) throw errorToThrow!;
    return detailsResult ??
        const PlaceDetails(
          placeId: '',
          name: '',
          formattedAddress: '',
          latitude: 0,
          longitude: 0,
        );
  }
}

void main() {
  // ═══════════════════════════════════════════
  // PlaceSuggestion Entity Tests
  // ═══════════════════════════════════════════
  group('PlaceSuggestion', () {
    test('يجب أن يدعم مقارنة المساواة (Equatable)', () {
      const suggestion1 = PlaceSuggestion(
        placeId: 'abc123',
        mainText: 'مستشفى الثورة',
        secondaryText: 'صنعاء, اليمن',
        fullDescription: 'مستشفى الثورة, صنعاء, اليمن',
      );
      const suggestion2 = PlaceSuggestion(
        placeId: 'abc123',
        mainText: 'مستشفى الثورة',
        secondaryText: 'صنعاء, اليمن',
        fullDescription: 'مستشفى الثورة, صنعاء, اليمن',
      );
      expect(suggestion1, equals(suggestion2));
    });

    test('اقتراحان مختلفان يجب أن لا يتساويا', () {
      const suggestion1 = PlaceSuggestion(
        placeId: 'abc123',
        mainText: 'مستشفى الثورة',
        secondaryText: 'صنعاء',
        fullDescription: 'مستشفى الثورة, صنعاء',
      );
      const suggestion2 = PlaceSuggestion(
        placeId: 'xyz456',
        mainText: 'جامعة صنعاء',
        secondaryText: 'صنعاء',
        fullDescription: 'جامعة صنعاء, صنعاء',
      );
      expect(suggestion1, isNot(equals(suggestion2)));
    });
  });

  // ═══════════════════════════════════════════
  // PlaceDetails Entity Tests
  // ═══════════════════════════════════════════
  group('PlaceDetails', () {
    test('يجب أن يدعم مقارنة المساواة (Equatable)', () {
      const details1 = PlaceDetails(
        placeId: 'abc123',
        name: 'مستشفى الثورة',
        formattedAddress: 'صنعاء, اليمن',
        latitude: 15.3694,
        longitude: 44.1910,
      );
      const details2 = PlaceDetails(
        placeId: 'abc123',
        name: 'مستشفى الثورة',
        formattedAddress: 'صنعاء, اليمن',
        latitude: 15.3694,
        longitude: 44.1910,
      );
      expect(details1, equals(details2));
    });

    test('يجب أن يحفظ الإحداثيات بشكل صحيح', () {
      const details = PlaceDetails(
        placeId: 'test',
        name: 'مكان اختبار',
        formattedAddress: 'عنوان اختبار',
        latitude: 15.369445,
        longitude: 44.191007,
      );
      expect(details.latitude, 15.369445);
      expect(details.longitude, 44.191007);
    });
  });

  // ═══════════════════════════════════════════
  // SearchPlacesUseCase Tests
  // ═══════════════════════════════════════════
  group('SearchPlacesUseCase', () {
    late FakePlaceSearchRepository fakeRepo;
    late SearchPlacesUseCase useCase;

    setUp(() {
      fakeRepo = FakePlaceSearchRepository();
      useCase = SearchPlacesUseCase(fakeRepo);
    });

    test('نجاح — يعيد قائمة اقتراحات', () async {
      fakeRepo.searchResult = const [
        PlaceSuggestion(
          placeId: 'p1',
          mainText: 'مستشفى الثورة',
          secondaryText: 'صنعاء',
          fullDescription: 'مستشفى الثورة, صنعاء',
        ),
        PlaceSuggestion(
          placeId: 'p2',
          mainText: 'جامعة صنعاء',
          secondaryText: 'صنعاء',
          fullDescription: 'جامعة صنعاء, صنعاء',
        ),
      ];

      final results = await useCase(query: 'صنعاء');
      expect(results.length, 2);
      expect(results[0].mainText, 'مستشفى الثورة');
      expect(results[1].placeId, 'p2');
      expect(fakeRepo.searchCallCount, 1);
      expect(fakeRepo.lastQuery, 'صنعاء');
    });

    test('نجاح — قائمة فارغة عند عدم وجود نتائج', () async {
      fakeRepo.searchResult = [];

      final results = await useCase(query: 'مكان_غير_موجود');
      expect(results, isEmpty);
      expect(fakeRepo.searchCallCount, 1);
    });

    test('فشل — يرمي استثناء عند خطأ الشبكة', () async {
      fakeRepo.errorToThrow = Exception('فشل الاتصال بالشبكة');

      expect(
        () => useCase(query: 'صنعاء'),
        throwsA(isA<Exception>()),
      );
    });

    test('يمرر sessionToken و location بشكل صحيح', () async {
      fakeRepo.searchResult = [];

      await useCase(
        query: 'مكان',
        sessionToken: 'token123',
        latitude: 15.0,
        longitude: 44.0,
      );

      expect(fakeRepo.lastSessionToken, 'token123');
    });
  });

  // ═══════════════════════════════════════════
  // GetPlaceDetailsUseCase Tests
  // ═══════════════════════════════════════════
  group('GetPlaceDetailsUseCase', () {
    late FakePlaceSearchRepository fakeRepo;
    late GetPlaceDetailsUseCase useCase;

    setUp(() {
      fakeRepo = FakePlaceSearchRepository();
      useCase = GetPlaceDetailsUseCase(fakeRepo);
    });

    test('نجاح — يعيد تفاصيل المكان مع الإحداثيات', () async {
      fakeRepo.detailsResult = const PlaceDetails(
        placeId: 'place_abc',
        name: 'مستشفى الثورة',
        formattedAddress: 'شارع الزبيري, صنعاء, اليمن',
        latitude: 15.3694,
        longitude: 44.1910,
      );

      final details = await useCase(placeId: 'place_abc');
      expect(details.name, 'مستشفى الثورة');
      expect(details.latitude, 15.3694);
      expect(details.longitude, 44.1910);
      expect(fakeRepo.detailsCallCount, 1);
      expect(fakeRepo.lastPlaceId, 'place_abc');
    });

    test('فشل — يرمي استثناء عند عدم العثور على المكان', () async {
      fakeRepo.errorToThrow = Exception('تعذر العثور على تفاصيل المكان');

      expect(
        () => useCase(placeId: 'invalid_id'),
        throwsA(isA<Exception>()),
      );
    });

    test('يمرر sessionToken بشكل صحيح', () async {
      fakeRepo.detailsResult = const PlaceDetails(
        placeId: 'p1',
        name: 'مكان',
        formattedAddress: 'عنوان',
        latitude: 0,
        longitude: 0,
      );

      await useCase(placeId: 'p1', sessionToken: 'session_xyz');
      expect(fakeRepo.lastSessionToken, 'session_xyz');
    });
  });
}
