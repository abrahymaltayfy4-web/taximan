import '../../../../core/domain/account_status.dart';
import '../../domain/entities/client_entity.dart';
import '../models/client_model.dart';

abstract final class ClientMapper {
  static ClientEntity toEntity(ClientModel m, {String? fallbackName}) {
    return ClientEntity(
      uid: m.uid,
      name: m.name ?? fallbackName ?? '',
      email: m.email,
      phone: m.phone,
      accountStatus: _status(m),
    );
  }

  /// يدعم الحقل الجديد accountStatus ثم الحقل القديم isBlocked
  static AccountStatus _status(ClientModel m) {
    if (m.accountStatus != null) return AccountStatus.fromString(m.accountStatus);
    if (m.isBlocked) return AccountStatus.blocked;
    return AccountStatus.active;
  }
}
