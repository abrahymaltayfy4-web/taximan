// lib/features/auth/views/register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.charcoalBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'انضم إلينا',
                  style: GoogleFonts.cairo(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'أنشئ حساباً جديداً واستمتع بتجربة تنقل فريدة.',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: AppTheme.darkGrey,
                  ),
                ),
                SizedBox(height: 32.h),

                // Full Name Field
                Text(
                  'الاسم الكامل',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الاسم الكامل';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'محمد أحمد',
                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.darkGrey),
                  ),
                ),
                SizedBox(height: 20.h),

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
                SizedBox(height: 20.h),

                // Phone Number Field
                Text(
                  'رقم الهاتف',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '5xxxxxxxx',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.darkGrey),
                  ),
                ),
                SizedBox(height: 20.h),

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
                SizedBox(height: 36.h),

                // Register Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Trigger Register Cubit
                    }
                  },
                  child: const Text('إنشاء الحساب'),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}