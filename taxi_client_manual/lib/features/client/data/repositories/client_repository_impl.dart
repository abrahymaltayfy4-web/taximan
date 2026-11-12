import '../../../../core/auth/auth_session.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_data_source.dart';
import '../mappers/client_mapper.dart';

class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource _remote;
  final AuthSession _session;

  const ClientRepositoryImpl(this._remote, this._session);

  @override
  Future<Result<ClientEntity?>> getCurrentClient() async {
    final uid = _session.currentUserId;
    if (uid == null) return Result<ClientEntity?>.failure(const AuthFailure());
    return safeCall(() async {
      final model = await _remote.getClient(uid);
      return model == null ? null : ClientMapper.toEntity(model);
    });
  }

  @override
  Future<Result<void>> updateProfile({
    required String name,
    required String phone,
  }) async {
    final uid = _session.currentUserId;
    if (uid == null) return Result<void>.failure(const AuthFailure());
    return safeCall(() => _remote.updateProfile(uid, name: name, phone: phone));
  }
}
