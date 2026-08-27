// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'theme/app_theme.dart';
import 'features/auth/views/login_view.dart';
import 'features/home/views/home_view.dart';
import 'core/services/notification_service.dart';
import 'core/services/admin_notification_listener.dart';
import 'core/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// يعمل حتى لو التطبيق مغلق تماماً من الرام
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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

  runApp(const RahalCustomerApp());
}

class RahalCustomerApp extends StatelessWidget {
  const RahalCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Rahal Customer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const _AuthGate(),
        );
      },
    );
  }
}

/// يتحقق من حالة تسجيل الدخول ويوجه المستخدم للشاشة المناسبة
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
      // التحقق من أن الحساب عميل فعلاً
      final clientDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(user.uid)
          .get();
      if (clientDoc.exists) {
        // التحقق من حالة الحظر
        final data = clientDoc.data();
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
        setState(() {
          _isLoggedIn = true;
          _isLoading = false;
        });
        // بدء الاستماع لإشعارات الأدمن
        AdminNotificationListener.startListening(
          targetAll: 'all_users',
          targetSpecific: 'specific_user',
        );
        // تفعيل FCM للإشعارات عند إغلاق التطبيق
        FCMService.initialize(collectionName: 'clients');
        return;
      } else {
        // حساب كابتن — نسجل خروج
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

    return _isLoggedIn ? const HomeView() : const LoginView();
  }
}
