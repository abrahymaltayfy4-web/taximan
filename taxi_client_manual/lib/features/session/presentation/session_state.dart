import 'package:equatable/equatable.dart';
import '../../../core/shared/account_status.dart';

/// حالات الجلسة
sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// لم تُفحص بعد
class SessionInitial extends SessionState {
  const SessionInitial();
}

/// جاري التحقق
class SessionLoading extends SessionState {
  const SessionLoading();
}

/// مسجل دخول + حساب فعّال
class SessionAuthenticated extends SessionState {
  final String uid;
  final String name;

  const SessionAuthenticated({required this.uid, required this.name});

  @override
  List<Object?> get props => [uid, name];
}

/// غير مسجل دخول
class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

/// حساب محظور
class SessionBlocked extends SessionState {
  final AccountStatus status;
  const SessionBlocked(this.status);

  @override
  List<Object?> get props => [status];
}

/// حساب معلق بانتظار الموافقة (للكابتن)
class SessionPendingApproval extends SessionState {
  const SessionPendingApproval();
}

/// حساب مرفوض
class SessionRejected extends SessionState {
  const SessionRejected();
}
