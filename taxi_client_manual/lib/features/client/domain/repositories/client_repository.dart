import '../../../../core/error/result.dart';
import '../entities/client_entity.dart';

/// عقد بيانات العميل الحالي — Domain
abstract interface class ClientRepository {
  /// بيانات العميل الحالي، أو null إن لم يكن له مستند عميل
  Future<Result<ClientEntity?>> getCurrentClient();

  Future<Result<void>> updateProfile({
    required String name,
    required String phone,
  });
}
