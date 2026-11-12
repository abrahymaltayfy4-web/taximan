import '../../../../core/auth/auth_session.dart';
import '../../../../core/config/app_role.dart';
import '../../../../core/services/admin_notification_listener.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../client/data/datasources/client_remote_data_source.dart';
import '../../../client/data/mappers/client_mapper.dart';
import '../../domain/repositories/session_repository.dart';

/// تنفيذ SessionRepository للعميل
class SessionRepositoryImpl implements SessionRepository {
  final AuthSession _session;
  final ClientRemoteDataSource _clients;
  final AdminNotificationListener _adminNotifications;
  final PushNotificationService _push;

  SessionRepositoryImpl({
    required AuthSession session,
    required ClientRemoteDataSource clients,
    required AdminNotificationListener adminNotifications,
    required PushNotificationService push,
  }) : _session = session,
       _clients = clients,
       _adminNotifications = adminNotifications,
       _push = push;

  @override
  bool get hasCurrentUser => _session.currentUserId != null;

  @override
  Future<SessionInfo?> checkSession() async {
    final uid = _session.currentUserId;
    if (uid == null) return null;

    final model = await _clients.getClient(uid);

    // التحقق من أن الحساب عميل فعلاً (ليس كابتن)
    if (model == null) {
      await _session.signOut();
      return null;
    }

    final client = ClientMapper.toEntity(
      model,
      fallbackName: _session.fallbackDisplayName ?? 'عميل رحال',
    );
    return SessionInfo(
      uid: uid,
      name: client.name,
      accountStatus: client.accountStatus,
    );
  }

  @override
  Future<void> signOut() => _session.signOut();

  @override
  void startNotificationServices() {
    _adminNotifications.startListening(
      targetAll: AppRole.notificationTargetAll,
      targetSpecific: AppRole.notificationTargetSpecific,
    );
    _push.initialize(collectionName: AppRole.userCollection);
  }

  @override
  void stopNotificationServices() {
    _adminNotifications.stopListening();
  }
}
