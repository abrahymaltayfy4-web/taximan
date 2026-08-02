// lib/features/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taxi_client_manual/features/home/views/home_view.dart';
import '../../../theme/app_theme.dart';
import '../cubit/client_auth_cubit.dart';
import '../repositories/client_auth_repository.dart';
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
    return BlocProvider(
      create: (context) => ClientAuthCubit(ClientAuthRepository()),
      child: Scaffold(
        backgroundColor: AppTheme.creamBackground,
        body: SafeArea(
          child: BlocConsumer<ClientAuthCubit, ClientAuthState>(
            listener: (context, state) {
              if (state is ClientAuthenticated) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeView()),
                );
              } else if (state is ClientAuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: GoogleFonts.cairo()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40.h),
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
                      ElevatedButton(
                        onPressed: state is ClientAuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<ClientAuthCubit>().signIn(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text.trim(),
                                      );
                                }
                              },
                        child: state is ClientAuthLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('تسجيل الدخول'),
                      ),
                      SizedBox(height: 24.h),
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
              );
            },
          ),
        ),
      ),
    );
  }
}