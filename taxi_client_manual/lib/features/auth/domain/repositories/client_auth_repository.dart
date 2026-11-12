import '../../../../core/error/result.dart';
import '../../../client/domain/entities/client_entity.dart';

/// عقد مصادقة العميل — Domain
abstract interface class ClientAuthRepository {
  /// تسجيل الدخول. يفشل بـ [WrongAccountTypeFailure] إن كان الحساب كابتن.
  Future<Result<ClientEntity>> signIn({
    required String email,
    required String password,
  });

  /// إنشاء حساب عميل جديد وحفظ بياناته
  Future<Result<ClientEntity>> signUp({
    required String password,
    required NewClientData data,
  });
}
