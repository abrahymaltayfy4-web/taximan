// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. استيراد حزمة الفايربيز
import 'theme/app_theme.dart';
import 'features/driver_auth/views/driver_login_view.dart';
import 'features/driver_auth/cubit/driver_auth_cubit.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/driver_repository.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<DriverAuthCubit>(
          create: (context) => DriverAuthCubit(
            AuthRepository(FirebaseAuthService()),
            DriverRepository(FirestoreService()),
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Rahal Driver',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const DriverLoginView(),
          );
        },
      ),
    );
  }
}