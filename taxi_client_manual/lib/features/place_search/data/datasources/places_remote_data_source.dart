import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_suggestion_model.dart';
import '../models/place_details_model.dart';

/// مصدر البيانات الخارجي — يتعامل مع Google Places API مباشرةً
/// هذا هو المكان الوحيد الذي يتعامل مع HTTP و JSON
class PlacesRemoteDataSource {
  final String _apiKey;
  final http.Client _httpClient;

  static const String _autocompleteBaseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _detailsBaseUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  PlacesRemoteDataSource({
    required String apiKey,
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _httpClient = httpClient ?? http.Client();

  /// البحث عن أماكن — Google Places Autocomplete API
  Future<List<PlaceSuggestionModel>> autocomplete({
    required String query,
    String? sessionToken,
    double? latitude,
    double? longitude,
  }) async {
    if (query.trim().isEmpty) return [];

    final queryParams = <String, String>{
      'input': query,
      'key': _apiKey,
      'language': 'ar',
      'components': 'country:ye',
    };

    if (sessionToken != null) {
      queryParams['sessiontoken'] = sessionToken;
    }

    if (latitude != null && longitude != null) {
      queryParams['location'] = '$latitude,$longitude';
      queryParams['radius'] = '50000'; // 50 كم
    }

    final uri = Uri.parse(_autocompleteBaseUrl).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('فشل الاتصال بخدمة البحث: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status != 'OK' && status != 'ZERO_RESULTS') {
        throw Exception(
          data['error_message'] as String? ?? 'خطأ غير معروف من خدمة البحث',
        );
      }

      final predictions = data['predictions'] as List<dynamic>? ?? [];
      return predictions
          .map((p) =>
              PlaceSuggestionModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } on Exception {
      rethrow;
    }
  }

  /// جلب تفاصيل مكان — Google Place Details API
  Future<PlaceDetailsModel> fetchDetails({
    required String placeId,
    String? sessionToken,
  }) async {
    final queryParams = <String, String>{
      'place_id': placeId,
      'key': _apiKey,
      'fields': 'place_id,name,formatted_address,geometry',
      'language': 'ar',
    };

    if (sessionToken != null) {
      queryParams['sessiontoken'] = sessionToken;
    }

    final uri = Uri.parse(_detailsBaseUrl).replace(
      queryParameters: queryParams,
    );

    try {
      final response = await _httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('فشل جلب تفاصيل المكان: ${response.statusCode}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final status = data['status'] as String?;

      if (status != 'OK') {
        throw Exception(
          data['error_message'] as String? ?? 'تعذر العثور على تفاصيل المكان',
        );
      }

      return PlaceDetailsModel.fromJson(data);
    } on Exception {
      rethrow;
    }
  }
}
