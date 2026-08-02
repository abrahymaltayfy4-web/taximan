// lib/features/driver_auth/views/driver_register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../cubit/driver_auth_cubit.dart';
import '../../driver_home/views/driver_home_view.dart';

class DriverRegisterView extends StatefulWidget {
  const DriverRegisterView({Key? key}) : super(key: key);

  @override
  State<DriverRegisterView> createState() => _DriverRegisterViewState();
}

class _DriverRegisterViewState extends State<DriverRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carPlateController = TextEditingController();
  final _pricePerKmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _carModelController.dispose();
    _carPlateController.dispose();
    _pricePerKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('تسجيل كابتن جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.charcoalBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<DriverAuthCubit, DriverAuthState>(
        listener: (context, state) {
          if (state is DriverAuthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const DriverHomeView()),
              (route) => false,
            );
          } else if (state is DriverAuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بيانات الحساب الشخصي', style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),

                  Text('الاسم الكامل', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  TextFormField(controller: _nameController, validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null, decoration: const InputDecoration(hintText: 'الكابتن محمد')),
                  SizedBox(height: 16.h),

                  Text('البريد الإلكتروني', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null, decoration: const InputDecoration(hintText: 'driver@rahaltaxi.com')),
                  SizedBox(height: 16.h),

                  Text('كلمة المرور', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  TextFormField(controller: _passwordController, obscureText: true, validator: (v) => v!.length < 6 ? 'كلمة المرور قصيرة جداً' : null, decoration: const InputDecoration(hintText: '••••••••')),
                  SizedBox(height: 16.h),

                  Text('رقم الهاتف', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null, decoration: const InputDecoration(hintText: '7xxxxxxxx')),
                  SizedBox(height: 24.h),

                  Text('بيانات السيارة والتسعير', style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.h),

                  Text('نوع وموديل السيارة', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  TextFormField(controller: _carModelController, validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null, decoration: const InputDecoration(hintText: 'تويوتا كامري 2023')),
                  SizedBox(height: 16.h),

                  Text('رقم اللوحة', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  TextFormField(controller: _carPlateController, validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null, decoration: const InputDecoration(hintText: 'أ ب ج 1234')),
                  SizedBox(height: 16.h),

                  Text('سعر الكيلو (ر.ي)', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6.h),
                  TextFormField(controller: _pricePerKmController, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null, decoration: const InputDecoration(hintText: '500')),
                  SizedBox(height: 36.h),

                  state is DriverAuthLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.deepBurgundy))
                      : ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<DriverAuthCubit>().register(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    name: _nameController.text.trim(),
                                    phone: _phoneController.text.trim(),
                                    carModel: _carModelController.text.trim(),
                                    carPlate: _carPlateController.text.trim(),
                                    pricePerKm: double.tryParse(_pricePerKmController.text.trim()) ?? 0.0,
                                  );
                            }
                          },
                          child: const Text('إتمام التسجيل وبدء العمل'),
                        ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}