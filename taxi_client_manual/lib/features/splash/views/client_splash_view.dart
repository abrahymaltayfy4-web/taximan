import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/views/login_view.dart';
import '../../home/views/home_view.dart';
import '../cubit/client_splash_cubit.dart';
import '../cubit/client_splash_state.dart';

class ClientSplashView extends StatefulWidget {
  const ClientSplashView({super.key});

  @override
  State<ClientSplashView> createState() => _ClientSplashViewState();
}

class _ClientSplashViewState extends State<ClientSplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // بدء فحص الجلسة
    context.read<ClientSplashCubit>().initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      _buildFadeRoute(const HomeView()),
    );
  }

  void _navigateToLogin({String? message}) {
    Navigator.of(context).pushReplacement(
      _buildFadeRoute(const LoginView()),
    );

    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                message.contains('حظر') ? Colors.red : Colors.orange,
          ),
        );
      });
    }
  }

  void _navigateToPending() {
    Navigator.of(context).pushReplacement(
      _buildFadeRoute(
        const Scaffold(
          backgroundColor: AppTheme.creamBackground,
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'حسابك قيد المراجعة. سيتم إعلامك عند الموافقة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route<void> _buildFadeRoute(Widget page) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientSplashCubit, ClientSplashState>(
      listener: (context, state) {
        if (state is ClientSplashNavigateToHome) {
          _navigateToHome();
        } else if (state is ClientSplashNavigateToLogin) {
          _navigateToLogin(message: state.message);
        } else if (state is ClientSplashNavigateToPending) {
          _navigateToPending();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.deepBurgundy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // اللوقو / الأيقونة
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: AppTheme.creamBackground,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 60.w,
                      color: AppTheme.deepBurgundy,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // اسم التطبيق
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'وصّلني',
                    style: GoogleFonts.cairo(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.creamBackground,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // الوصف
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'وجهتك.. توصلك',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.creamBackground.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 60.h),

              // مؤشر التحميل
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    color: AppTheme.creamBackground,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
