import 'package:equatable/equatable.dart';

/// حالات شاشة Splash
sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية — الـ splash يعرض الأنيميشن
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// جاري فحص الجلسة
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// التنقل لشاشة الرئيسية (مصادق)
class SplashNavigateToHome extends SplashState {
  const SplashNavigateToHome();
}

/// التنقل لشاشة تسجيل الدخول
class SplashNavigateToLogin extends SplashState {
  final String? message;
  const SplashNavigateToLogin({this.message});

  @override
  List<Object?> get props => [message];
}
