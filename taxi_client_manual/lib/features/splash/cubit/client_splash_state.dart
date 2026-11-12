import 'package:equatable/equatable.dart';

/// حالات شاشة Splash
sealed class ClientSplashState extends Equatable {
  const ClientSplashState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية — الـ splash يعرض الأنيميشن
class ClientSplashInitial extends ClientSplashState {
  const ClientSplashInitial();
}

/// جاري فحص الجلسة
class ClientSplashLoading extends ClientSplashState {
  const ClientSplashLoading();
}

/// التنقل لشاشة الرئيسية (مصادق)
class ClientSplashNavigateToHome extends ClientSplashState {
  const ClientSplashNavigateToHome();
}

/// التنقل لشاشة انتظار الموافقة
class ClientSplashNavigateToPending extends ClientSplashState {
  const ClientSplashNavigateToPending();
}

/// التنقل لشاشة تسجيل الدخول
class ClientSplashNavigateToLogin extends ClientSplashState {
  final String? message;
  const ClientSplashNavigateToLogin({this.message});

  @override
  List<Object?> get props => [message];
}
