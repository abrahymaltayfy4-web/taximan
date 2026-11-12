// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/infrastructure/notification_service.dart';
import 'core/di/service_locator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/splash/cubit/splash_cubit.dart';
import 'features/splash/views/splash_view.dart';

/// يعمل حتى لو التطبيق مغلق تماماً من الرام
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // الإشعار يظهر تلقائياً من النظام — لا يحتاج كود إضافي
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // تسجيل background handler قبل أي شيء
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // تهيئة حاوية الاعتماديات
  await initDependencies();

  await NotificationService.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.deepBurgundy,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const WasslniDriverApp());
}

class WasslniDriverApp extends StatelessWidget {
  const WasslniDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Wasslni Driver',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: BlocProvider(
            create: (_) => sl<SplashCubit>(),
            child: const SplashView(),
          ),
        );
      },
    );
  }
}
