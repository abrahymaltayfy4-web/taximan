import '../../../../core/error/result.dart';
import '../entities/account_statement.dart';

abstract interface class AccountRepository {
  /// كشف حساب الكابتن الحالي
  Future<Result<AccountStatement>> getAccountStatement();
}
