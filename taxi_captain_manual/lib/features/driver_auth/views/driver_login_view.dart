// lib/features/driver_auth/views/driver_login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_captain_manual/features/driver_home/views/driver_home_view.dart';
import '../../../theme/app_theme.dart';
import 'driver_register_view.dart';

class DriverLoginView extends StatefulWidget {
  const DriverLoginView({Key? key}) : super(key: key);

  @override
  State<DriverLoginView> createState() => _DriverLoginViewState();
}

class _DriverLoginViewState extends State<DriverLoginView> {
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
                // Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppTheme.deepBurgundy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'بوابة الكباتن',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBurgundy,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'أهلاً بك أيها الكابتن',
                  style: GoogleFonts.cairo(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'سجل دخولك لبدء استقبال الرحلات وزيادة أرباحك.',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.darkGrey,
                  ),
                ),
                SizedBox(height: 48.h),

                // Email
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
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'driver@rahaltaxi.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.darkGrey),
                  ),
                ),
                SizedBox(height: 24.h),

                // Password
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
                SizedBox(height: 40.h),

                // Login Button
                ElevatedButton(
                  onPressed: () {
                    // if (_formKey.currentState!.validate()) {
                    //   // TODO: Driver Login Logic
                    // }
                    Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DriverHomeView()),
                        );
                  },
                  child: const Text('دخول الكابتن'),
                ),
                SizedBox(height: 24.h),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لا تمتلك حساب كابتن؟ ',
                      style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DriverRegisterView()),
                        );
                      },
                      child: Text(
                        'سجل معنا ككابتن',
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