import '../../../../core/error/result.dart';
import '../../../client/domain/entities/client_entity.dart';
import '../repositories/client_auth_repository.dart';

class SignUpClientUseCase {
  final ClientAuthRepository _repository;

  const SignUpClientUseCase(this._repository);

  Future<Result<ClientEntity>> call({
    required String password,
    required NewClientData data,
  }) {
    return _repository.signUp(password: password, data: data);
  }
}
