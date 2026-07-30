// lib/features/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_client_manual/features/home/views/home_view.dart';
import '../../../theme/app_theme.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                // Header Title
                Text(
                  'أهلاً بك مجدداً',
                  style: GoogleFonts.cairo(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'سجل دخولك لاستدامة رحلاتك بكل راحة وفخامة.',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.darkGrey,
                  ),
                ),
                SizedBox(height: 48.h),

                // Email Field
                Text(
                  'البريد الإلكتروني',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.darkGrey),
                  ),
                ),
                SizedBox(height: 24.h),

                // Password Field
                Text(
                  'كلمة المرور',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال كلمة المرور';
                    }
                    if (value.length < 6) {
                      return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.darkGrey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.darkGrey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Forgot Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement Forgot Password Logic
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text(
                      'هل نسيت كلمة المرور؟',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepBurgundy,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 36.h),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Trigger Login Cubit
                      
                    }
                    Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeView()),
                        );
                  },
                  child: const Text('تسجيل الدخول'),
                ),
                SizedBox(height: 24.h),

                // Navigate to Register View
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟ ',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterView()),
                        );
                      },
                      child: Text(
                        'انشئ حساباً الآن',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepBurgundy,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}