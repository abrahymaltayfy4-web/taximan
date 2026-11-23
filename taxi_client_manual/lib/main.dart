import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/theme/app_theme.dart';
import 'core/infrastructure/notification_service.dart';
import 'core/di/service_locator.dart';
import 'features/splash/cubit/client_splash_cubit.dart';
import 'features/splash/views/client_splash_view.dart';

/// يعمل حتى لو التطبيق مغلق تماماً من الرام
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

  runApp(const WasslniCustomerApp());
}

class WasslniCustomerApp extends StatelessWidget {
  const WasslniCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Wasslni',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          builder: (context, widget) {
            // تحديد حد أقصى لحجم الخط لتجنب overflow على أجهزة أخرى
            final mediaQueryData = MediaQuery.of(context);
            final constrainedTextScaler = mediaQueryData.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.1,
            );
            return MediaQuery(
              data: mediaQueryData.copyWith(textScaler: constrainedTextScaler),
              child: widget!,
            );
          },
          home: BlocProvider(
            create: (_) => sl<ClientSplashCubit>(),
            child: const ClientSplashView(),
          ),
        );
      },
    );
  }
}
