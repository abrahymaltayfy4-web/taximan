import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/usecases/check_client_session_use_case.dart';
import 'client_splash_state.dart';

/// Cubit شاشة Splash للعميل — يدير فحص الجلسة والتنقل
class ClientSplashCubit extends Cubit<ClientSplashState> {
  final CheckClientSessionUseCase _checkSession;

  ClientSplashCubit(this._checkSession)
      : super(const ClientSplashInitial());

  /// يبدأ فحص الجلسة
  Future<void> initialize() async {
    emit(const ClientSplashLoading());

    try {
      final result = await _checkSession();

      switch (result) {
        case ClientSplashResult.authenticated:
          emit(const ClientSplashNavigateToHome());

        case ClientSplashResult.blocked:
          emit(const ClientSplashNavigateToLogin(
            message: 'تم حظر حسابك. تواصل مع الإدارة.',
          ));

        case ClientSplashResult.pendingApproval:
          emit(const ClientSplashNavigateToPending());

        case ClientSplashResult.rejected:
          emit(const ClientSplashNavigateToLogin(
            message: 'تم رفض طلب تسجيلك. تواصل مع الإدارة.',
          ));

        case ClientSplashResult.unauthenticated:
          emit(const ClientSplashNavigateToLogin());
      }
    } catch (_) {
      emit(const ClientSplashNavigateToLogin());
    }
  }
}
