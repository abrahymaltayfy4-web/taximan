import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:taxi_client_manual/features/place_search/domain/entities/place_suggestion.dart';
import 'package:taxi_client_manual/features/place_search/domain/entities/place_details.dart';
import 'package:taxi_client_manual/features/place_search/domain/repositories/place_search_repository.dart';
import 'package:taxi_client_manual/features/place_search/domain/usecases/search_places_use_case.dart';
import 'package:taxi_client_manual/features/place_search/domain/usecases/get_place_details_use_case.dart';
import 'package:taxi_client_manual/features/place_search/presentation/cubit/place_search_cubit.dart';
import 'package:taxi_client_manual/features/place_search/presentation/cubit/place_search_state.dart';

// ═══════════════════════════════════════════
// Fake Repository
// ═══════════════════════════════════════════
class FakePlaceSearchRepository implements PlaceSearchRepository {
  List<PlaceSuggestion>? searchResult;
  PlaceDetails? detailsResult;
  Exception? searchError;
  Exception? detailsError;

  @override
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    String? sessionToken,
    double? latitude,
    double? longitude,
  }) async {
    if (searchError != null) throw searchError!;
    return searchResult ?? [];
  }

  @override
  Future<PlaceDetails> getPlaceDetails({
    required String placeId,
    String? sessionToken,
  }) async {
    if (detailsError != null) throw detailsError!;
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
  late FakePlaceSearchRepository fakeRepo;

  setUp(() {
    fakeRepo = FakePlaceSearchRepository();
  });

  PlaceSearchCubit buildCubit() {
    return PlaceSearchCubit(
      searchPlaces: SearchPlacesUseCase(fakeRepo),
      getPlaceDetails: GetPlaceDetailsUseCase(fakeRepo),
    );
  }

  // ═══════════════════════════════════════════
  // الحالة الأولية
  // ═══════════════════════════════════════════
  group('PlaceSearchCubit الحالة الأولية', () {
    test('الحالة الأولية هي PlaceSearchInitial', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<PlaceSearchInitial>());
      cubit.close();
    });
  });

  // ═══════════════════════════════════════════
  // clearSearch
  // ═══════════════════════════════════════════
  group('PlaceSearchCubit.clearSearch', () {
    blocTest<PlaceSearchCubit, PlaceSearchState>(
      'يعيد الحالة إلى PlaceSearchInitial',
      build: buildCubit,
      act: (cubit) => cubit.clearSearch(),
      expect: () => [isA<PlaceSearchInitial>()],
    );
  });

  // ═══════════════════════════════════════════
  // onQueryChanged
  // ═══════════════════════════════════════════
  group('PlaceSearchCubit.onQueryChanged', () {
    blocTest<PlaceSearchCubit, PlaceSearchState>(
      'نص فارغ → PlaceSearchInitial',
      build: buildCubit,
      act: (cubit) => cubit.onQueryChanged(''),
      expect: () => [isA<PlaceSearchInitial>()],
    );

    blocTest<PlaceSearchCubit, PlaceSearchState>(
      'حرف واحد → لا يبحث (أقل من 2)',
      build: buildCubit,
      act: (cubit) => cubit.onQueryChanged('م'),
      wait: const Duration(milliseconds: 600),
      expect: () => [], // لا حالة جديدة
    );

    blocTest<PlaceSearchCubit, PlaceSearchState>(
      'بحث ناجح → Loading ثم Loaded',
      build: () {
        fakeRepo.searchResult = const [
          PlaceSuggestion(
            placeId: 'p1',
            mainText: 'مستشفى الثورة',
            secondaryText: 'صنعاء',
            fullDescription: 'مستشفى الثورة, صنعاء',
          ),
        ];
        return buildCubit();
      },
      act: (cubit) => cubit.onQueryChanged('مستشفى'),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        isA<PlaceSearchLoading>(),
        isA<PlaceSearchLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as PlaceSearchLoaded;
        expect(state.suggestions.length, 1);
        expect(state.suggestions.first.mainText, 'مستشفى الثورة');
      },
    );

    blocTest<PlaceSearchCubit, PlaceSearchState>(
      'بحث بدون نتائج → Loading ثم Empty',
      build: () {
        fakeRepo.searchResult = [];
        return buildCubit();
      },
      act: (cubit) => cubit.onQueryChanged('مكان_غير_موجود_ابدا'),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        isA<PlaceSearchLoading>(),
        isA<PlaceSearchEmpty>(),
      ],
    );

    blocTest<PlaceSearchCubit, PlaceSearchState>(
      'خطأ في البحث → Loading ثم Error',
      build: () {
        fakeRepo.searchError = Exception('فشل الاتصال');
        return buildCubit();
      },
      act: (cubit) => cubit.onQueryChanged('صنعاء'),
      wait: const Duration(milliseconds: 600),
      expect: () => [
        isA<PlaceSearchLoading>(),
        isA<PlaceSearchError>(),
      ],
    );
  });

  // ═══════════════════════════════════════════
  // selectPlace
  // ═══════════════════════════════════════════
  group('PlaceSearchCubit.selectPlace', () {
    blocTest<PlaceSearchCubit, PlaceSearchState>(
      'نجاح → PlaceDetailsLoading ثم PlaceDetailsLoaded',
      build: () {
        fakeRepo.detailsResult = const PlaceDetails(
          placeId: 'place_abc',
          name: 'مستشفى الثورة',
          formattedAddress: 'صنعاء, اليمن',
          latitude: 15.3694,
          longitude: 44.1910,
        );
        return buildCubit();
      },
      act: (cubit) => cubit.selectPlace('place_abc'),
      expect: () => [
        isA<PlaceDetailsLoading>(),
        isA<PlaceDetailsLoaded>(),
      ],
      verify: (cubit) {
        final state = cubit.state as PlaceDetailsLoaded;
        expect(state.details.name, 'مستشفى الثورة');
        expect(state.details.latitude, 15.3694);
        expect(state.details.longitude, 44.1910);
      },
    );

    blocTest<PlaceSearchCubit, PlaceSearchState>(
      'فشل → PlaceDetailsLoading ثم PlaceDetailsError',
      build: () {
        fakeRepo.detailsError = Exception('تعذر العثور على المكان');
        return buildCubit();
      },
      act: (cubit) => cubit.selectPlace('invalid_id'),
      expect: () => [
        isA<PlaceDetailsLoading>(),
        isA<PlaceDetailsError>(),
      ],
    );
  });

  // ═══════════════════════════════════════════
  // setCurrentLocation
  // ═══════════════════════════════════════════
  group('PlaceSearchCubit.setCurrentLocation', () {
    test('لا يغيّر الحالة — فقط يحفظ الموقع للاستخدام في البحث', () {
      final cubit = buildCubit();
      cubit.setCurrentLocation(15.369, 44.191);
      expect(cubit.state, isA<PlaceSearchInitial>());
      cubit.close();
    });
  });
}
