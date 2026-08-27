// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme/app_theme.dart';
import 'features/driver_auth/views/driver_login_view.dart';
import 'features/driver_home/views/driver_home_view.dart';
import 'features/driver_auth/cubit/driver_auth_cubit.dart';
import 'core/services/firebase_auth_service.dart';
import 'core/services/firestore_service.dart';
import 'repositories/auth_repository.dart';
import 'repositories/driver_repository.dart';
import 'core/services/notification_service.dart';
import 'core/services/admin_notification_listener.dart';
import 'core/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  
  await NotificationService.initialize();

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
  const RahalDriverApp({super.key});

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
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

/// يتحقق من حالة تسجيل الدخول ويوجه الكابتن للشاشة المناسبة
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // التحقق من أن الحساب كابتن فعلاً
      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(user.uid)
          .get();
      if (driverDoc.exists) {
        final data = driverDoc.data();
        // التحقق من حالة الحظر
        if (data?['isBlocked'] == true) {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حظر حسابك. تواصل مع الإدارة.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() { _isLoading = false; });
          return;
        }
        // التحقق من حالة الموافقة
        final approvalStatus = data?['approvalStatus'] ?? 'approved';
        if (approvalStatus == 'pending') {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('حسابك قيد المراجعة. سيتم إعلامك عند الموافقة.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          setState(() { _isLoading = false; });
          return;
        }
        if (approvalStatus == 'rejected') {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم رفض طلب تسجيلك. تواصل مع الإدارة.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() { _isLoading = false; });
          return;
        }
        setState(() {
          _isLoggedIn = true;
          _isLoading = false;
        });
        // بدء الاستماع لإشعارات الأدمن
        AdminNotificationListener.startListening(
          targetAll: 'all_drivers',
          targetSpecific: 'specific_driver',
        );
        // تفعيل FCM للإشعارات عند إغلاق التطبيق
        FCMService.initialize(collectionName: 'drivers');
        return;
      } else {
        // حساب عميل — نسجل خروج
        await FirebaseAuth.instance.signOut();
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.creamBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.deepBurgundy),
        ),
      );
    }

    return _isLoggedIn ? const DriverHomeView() : const DriverLoginView();
  }
}