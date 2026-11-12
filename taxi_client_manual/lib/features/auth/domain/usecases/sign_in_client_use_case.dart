import '../../../../core/error/result.dart';
import '../../../client/domain/entities/client_entity.dart';
import '../repositories/client_auth_repository.dart';

class SignInClientUseCase {
  final ClientAuthRepository _repository;

  const SignInClientUseCase(this._repository);

  Future<Result<ClientEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}
