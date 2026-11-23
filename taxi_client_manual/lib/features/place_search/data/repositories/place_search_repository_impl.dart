import '../../domain/entities/place_suggestion.dart';
import '../../domain/entities/place_details.dart';
import '../../domain/repositories/place_search_repository.dart';
import '../datasources/places_remote_data_source.dart';

/// تنفيذ عقد المستودع — يربط الـ Domain بالـ Data Source
/// Dependency Inversion: يعتمد على الـ abstraction لا على الـ concrete
class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  final PlacesRemoteDataSource _dataSource;

  const PlaceSearchRepositoryImpl(this._dataSource);

  @override
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    String? sessionToken,
    double? latitude,
    double? longitude,
  }) async {
    return _dataSource.autocomplete(
      query: query,
      sessionToken: sessionToken,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<PlaceDetails> getPlaceDetails({
    required String placeId,
    String? sessionToken,
  }) async {
    return _dataSource.fetchDetails(
      placeId: placeId,
      sessionToken: sessionToken,
    );
  }
}
