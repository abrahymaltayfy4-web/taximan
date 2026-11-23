import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_client_manual/features/place_search/data/models/place_suggestion_model.dart';
import 'package:taxi_client_manual/features/place_search/data/models/place_details_model.dart';

void main() {
  // ═══════════════════════════════════════════
  // PlaceSuggestionModel.fromJson
  // ═══════════════════════════════════════════
  group('PlaceSuggestionModel.fromJson', () {
    test('يحوّل JSON كامل بشكل صحيح', () {
      final json = {
        'place_id': 'ChIJ_abc123',
        'description': 'مستشفى الثورة, شارع الزبيري, صنعاء, اليمن',
        'structured_formatting': {
          'main_text': 'مستشفى الثورة',
          'secondary_text': 'شارع الزبيري, صنعاء, اليمن',
        },
      };

      final model = PlaceSuggestionModel.fromJson(json);

      expect(model.placeId, 'ChIJ_abc123');
      expect(model.mainText, 'مستشفى الثورة');
      expect(model.secondaryText, 'شارع الزبيري, صنعاء, اليمن');
      expect(model.fullDescription,
          'مستشفى الثورة, شارع الزبيري, صنعاء, اليمن');
    });

    test('يتعامل مع structured_formatting مفقود', () {
      final json = {
        'place_id': 'xyz',
        'description': 'مكان اختبار',
      };

      final model = PlaceSuggestionModel.fromJson(json);

      expect(model.placeId, 'xyz');
      expect(model.mainText, 'مكان اختبار'); // fallback to description
      expect(model.secondaryText, '');
    });

    test('يتعامل مع JSON فارغ تقريباً بأمان', () {
      final json = <String, dynamic>{};

      final model = PlaceSuggestionModel.fromJson(json);

      expect(model.placeId, '');
      expect(model.mainText, '');
      expect(model.secondaryText, '');
      expect(model.fullDescription, '');
    });
  });

  // ═══════════════════════════════════════════
  // PlaceDetailsModel.fromJson
  // ═══════════════════════════════════════════
  group('PlaceDetailsModel.fromJson', () {
    test('يحوّل JSON كامل (مع result wrapper) بشكل صحيح', () {
      final json = {
        'result': {
          'place_id': 'ChIJ_abc123',
          'name': 'مستشفى الثورة',
          'formatted_address': 'شارع الزبيري, صنعاء, اليمن',
          'geometry': {
            'location': {
              'lat': 15.3694,
              'lng': 44.1910,
            },
          },
        },
      };

      final model = PlaceDetailsModel.fromJson(json);

      expect(model.placeId, 'ChIJ_abc123');
      expect(model.name, 'مستشفى الثورة');
      expect(model.formattedAddress, 'شارع الزبيري, صنعاء, اليمن');
      expect(model.latitude, 15.3694);
      expect(model.longitude, 44.1910);
    });

    test('يحوّل JSON مسطح (بدون result wrapper) بشكل صحيح', () {
      final json = {
        'place_id': 'ChIJ_flat',
        'name': 'جامعة صنعاء',
        'formatted_address': 'صنعاء',
        'geometry': {
          'location': {
            'lat': 15.35,
            'lng': 44.20,
          },
        },
      };

      final model = PlaceDetailsModel.fromJson(json);

      expect(model.placeId, 'ChIJ_flat');
      expect(model.name, 'جامعة صنعاء');
      expect(model.latitude, 15.35);
      expect(model.longitude, 44.20);
    });

    test('يتعامل مع geometry مفقود بأمان', () {
      final json = {
        'result': {
          'place_id': 'no_geo',
          'name': 'مكان بدون إحداثيات',
          'formatted_address': 'عنوان',
        },
      };

      final model = PlaceDetailsModel.fromJson(json);

      expect(model.placeId, 'no_geo');
      expect(model.latitude, 0.0);
      expect(model.longitude, 0.0);
    });

    test('يتعامل مع JSON فارغ تقريباً بأمان', () {
      final json = <String, dynamic>{};

      final model = PlaceDetailsModel.fromJson(json);

      expect(model.placeId, '');
      expect(model.name, '');
      expect(model.latitude, 0.0);
      expect(model.longitude, 0.0);
    });

    test('يقبل إحداثيات integer (ليس فقط double)', () {
      final json = {
        'result': {
          'place_id': 'int_coords',
          'name': 'مكان',
          'formatted_address': 'عنوان',
          'geometry': {
            'location': {
              'lat': 15,
              'lng': 44,
            },
          },
        },
      };

      final model = PlaceDetailsModel.fromJson(json);

      expect(model.latitude, 15.0);
      expect(model.longitude, 44.0);
    });
  });
}
