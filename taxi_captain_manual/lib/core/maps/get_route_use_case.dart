import '../domain/location_entity.dart';
import 'directions_repository.dart';
import 'route_info.dart';

class GetRouteUseCase {
  final DirectionsRepository _repository;

  const GetRouteUseCase(this._repository);

  Future<RouteInfo?> call({
    required LocationEntity origin,
    required LocationEntity destination,
  }) {
    return _repository.getRoute(origin: origin, destination: destination);
  }
}
