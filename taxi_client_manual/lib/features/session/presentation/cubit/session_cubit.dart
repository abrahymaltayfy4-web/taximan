import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/account_status.dart';
import '../../domain/repositories/session_repository.dart';
import 'session_state.dart';

/// Cubit إدارة الجلسة — يتولى كل منطق المصادقة والصلاحيات
class SessionCubit extends Cubit<SessionState> {
  final SessionRepository _repository;

  SessionCubit(this._repository) : super(const SessionInitial());

  /// فحص حالة الجلسة عند بدء التطبيق
  Future<void> checkSession() async {
    emit(const SessionLoading());

    try {
      final session = await _repository.checkSession();

      if (session == null) {
        emit(const SessionUnauthenticated());
        return;
      }

      // توجيه حسب حالة الحساب
      switch (session.accountStatus) {
        case AccountStatus.active:
          _repository.startNotificationServices();
          emit(SessionAuthenticated(uid: session.uid, name: session.name));

        case AccountStatus.pending:
          emit(const SessionPendingApproval());

        case AccountStatus.rejected:
          await _repository.signOut();
          emit(const SessionRejected());

        case AccountStatus.suspended:
        case AccountStatus.blocked:
        case AccountStatus.disabled:
          await _repository.signOut();
          _repository.stopNotificationServices();
          emit(SessionBlocked(session.accountStatus));
      }
    } catch (e) {
      emit(const SessionUnauthenticated());
    }
  }

  /// تسجيل خروج يدوي
  Future<void> signOut() async {
    _repository.stopNotificationServices();
    await _repository.signOut();
    emit(const SessionUnauthenticated());
  }

  /// بعد نجاح تسجيل الدخول/التسجيل — إعادة فحص
  Future<void> onLoginSuccess() => checkSession();
}
