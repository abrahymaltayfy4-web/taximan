/// Domain — Client Splash Use Case
/// يتحقق من حالة المصادقة بعد انتظار مدة الـ splash
library;

import '../../../session/domain/session_repository.dart';
import '../../../../core/shared/account_status.dart';

/// نتيجة فحص الـ splash
enum ClientSplashResult {
  authenticated,
  blocked,
  pendingApproval,
  rejected,
  unauthenticated,
}

class CheckClientSessionUseCase {
  final SessionRepository _sessionRepository;

  CheckClientSessionUseCase(this._sessionRepository);

  /// ينتظر [minDelay] ثم يفحص الجلسة
  Future<ClientSplashResult> call({
    Duration minDelay = const Duration(seconds: 2),
  }) async {
    // ننتظر الحد الأدنى لعرض الـ splash
    await Future.delayed(minDelay);

    final session = await _sessionRepository.checkSession();

    if (session == null) return ClientSplashResult.unauthenticated;

    switch (session.accountStatus) {
      case AccountStatus.active:
        _sessionRepository.startNotificationServices();
        return ClientSplashResult.authenticated;

      case AccountStatus.pending:
        return ClientSplashResult.pendingApproval;

      case AccountStatus.rejected:
        await _sessionRepository.signOut();
        return ClientSplashResult.rejected;

      case AccountStatus.suspended:
      case AccountStatus.blocked:
      case AccountStatus.disabled:
        await _sessionRepository.signOut();
        _sessionRepository.stopNotificationServices();
        return ClientSplashResult.blocked;
    }
  }
}
