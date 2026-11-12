import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/infrastructure/admin_notification_listener.dart';
import '../../../core/infrastructure/fcm_service.dart';
import '../domain/usecases/check_driver_session_use_case.dart';
import 'splash_state.dart';

/// Cubit شاشة Splash — يدير فحص الجلسة والتنقل
/// لا يعرف أي شيء عن الـ UI أو Firebase مباشرة
class SplashCubit extends Cubit<SplashState> {
  final CheckDriverSessionUseCase _checkSession;

  SplashCubit(this._checkSession) : super(const SplashInitial());

  /// يبدأ فحص الجلسة
  Future<void> initialize() async {
    emit(const SplashLoading());

    final result = await _checkSession();

    switch (result) {
      case SplashResult.authenticated:
        emit(const SplashNavigateToHome());

      case SplashResult.blocked:
        emit(const SplashNavigateToLogin(
          message: 'تم حظر حسابك. تواصل مع الإدارة.',
        ));

      case SplashResult.pendingApproval:
        emit(const SplashNavigateToLogin(
          message: 'حسابك قيد المراجعة. سيتم إعلامك عند الموافقة.',
        ));

      case SplashResult.rejected:
        emit(const SplashNavigateToLogin(
          message: 'تم رفض طلب تسجيلك. تواصل مع الإدارة.',
        ));

      case SplashResult.unauthenticated:
        emit(const SplashNavigateToLogin());
    }
  }

  /// تفعيل خدمات الإشعارات — يُستدعى عند التنقل للصفحة الرئيسية
  void initializeNotifications() {
    AdminNotificationListener.startListening(
      targetAll: 'all_drivers',
      targetSpecific: 'specific_driver',
    );
    FCMService.initialize(collectionName: 'drivers');
  }
}
