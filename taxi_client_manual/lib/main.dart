// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'theme/app_theme.dart';
import 'features/auth/views/login_view.dart';
import 'core/services/notification_service.dart';
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();

  // Set preferred orientations to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style matching the luxury theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.creamBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const RahalCustomerApp());
}

class RahalCustomerApp extends StatelessWidget {
  const RahalCustomerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design across all screen sizes
    return ScreenUtilInit(
      designSize: const Size(
        375,
        812,
      ), // Standard mobile design viewport (iPhone 11/12/13/14 reference)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Rahal Customer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          // Starting with LoginView as the initial screen
          home: const LoginView(),
        );
      },
    );
  }
}
