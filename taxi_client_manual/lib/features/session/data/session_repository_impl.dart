// session_repository_impl.dart
import '../../../core/infrastructure/admin_notification_listener.dart';
import '../../../core/infrastructure/fcm_service.dart';
import '../domain/session_repository.dart';
import 'firebase_session_data_source.dart';

/// تنفيذ SessionRepository للعميل
class SessionRepositoryImpl implements SessionRepository {
  final FirebaseSessionDataSource _dataSource;

  SessionRepositoryImpl(this._dataSource);

  @override
  bool get hasCurrentUser => _dataSource.currentUser != null;

  @override
  Future<SessionInfo?> checkSession() async {
    final user = _dataSource.currentUser;
    if (user == null) return null;

    // جلب بيانات العميل
    final clientData = await _dataSource.getClientData(user.uid);

    // التحقق من أن الحساب عميل فعلاً (ليس كابتن)
    if (clientData == null) {
      await _dataSource.signOut();
      return null;
    }

    final status = _dataSource.extractAccountStatus(clientData);
    final name =
        clientData['name'] ?? user.displayName ?? user.email ?? 'عميل رحال';

    return SessionInfo(uid: user.uid, name: name, accountStatus: status);
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  void startNotificationServices() {
    AdminNotificationListener.startListening(
      targetAll: 'all_users',
      targetSpecific: 'specific_user',
    );
    FCMService.initialize(collectionName: 'clients');
  }

  @override
  void stopNotificationServices() {
    // يمكن إضافة إيقاف listener هنا لاحقاً
  }
}
