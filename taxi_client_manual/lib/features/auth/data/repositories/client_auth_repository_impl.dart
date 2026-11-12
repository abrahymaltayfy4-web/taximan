import '../../../../core/error/app_exceptions.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/result.dart';
import '../../../client/data/datasources/client_remote_data_source.dart';
import '../../../client/data/mappers/client_mapper.dart';
import '../../../client/domain/entities/client_entity.dart';
import '../../domain/repositories/client_auth_repository.dart';
import '../datasources/client_auth_remote_data_source.dart';

class ClientAuthRepositoryImpl implements ClientAuthRepository {
  final ClientAuthRemoteDataSource _auth;
  final ClientRemoteDataSource _clients;

  const ClientAuthRepositoryImpl(this._auth, this._clients);

  @override
  Future<Result<ClientEntity>> signIn({
    required String email,
    required String password,
  }) {
    return safeCall(() async {
      final uid = await _auth.signInWithEmail(email: email, password: password);
      final model = await _clients.getClient(uid);
      if (model == null) {
        // هذا حساب كابتن وليس عميل — نرفض الدخول
        await _auth.signOut();
        throw const WrongAccountTypeException();
      }
      return ClientMapper.toEntity(model);
    });
  }

  @override
  Future<Result<ClientEntity>> signUp({
    required String password,
    required NewClientData data,
  }) {
    return safeCall(() async {
      final uid = await _auth.registerWithEmail(
        email: data.email,
        password: password,
      );
      await _clients.createClient(
        uid: uid,
        name: data.name,
        email: data.email,
        phone: data.phone,
      );
      return ClientEntity(
        uid: uid,
        name: data.name,
        email: data.email,
        phone: data.phone,
      );
    });
  }
}
