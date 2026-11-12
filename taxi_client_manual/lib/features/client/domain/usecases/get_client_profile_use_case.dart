import '../../../../core/error/result.dart';
import '../entities/client_entity.dart';
import '../repositories/client_repository.dart';

/// جلب الملف الشخصي للعميل الحالي — يفشل إن لم يوجد ملف
class GetClientProfileUseCase {
  final ClientRepository _repository;

  const GetClientProfileUseCase(this._repository);

  Future<Result<ClientEntity>> call() async {
    final result = await _repository.getCurrentClient();
    switch (result) {
      case Success(data: final client):
        if (client == null) {
          return Result.failure(const AccountNotFoundFailure());
        }
        return Result.success(client);
      case Err(failure: final f):
        return Result.failure(f);
    }
  }
}
