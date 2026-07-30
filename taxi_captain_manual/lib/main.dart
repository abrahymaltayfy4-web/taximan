// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'theme/app_theme.dart';
import 'features/driver_auth/views/driver_login_view.dart';

void main() {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const RahalDriverApp());
}

class RahalDriverApp extends StatelessWidget {
  const RahalDriverApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design across all screen sizes
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard mobile viewport reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Rahal Driver',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          // Starting with DriverLoginView as the initial screen for the Driver app
          home: const DriverLoginView(),
        );
      },
    );
  }
}