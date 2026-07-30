// lib/features/driver_auth/views/driver_register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class DriverRegisterView extends StatefulWidget {
  const DriverRegisterView({Key? key}) : super(key: key);

  @override
  State<DriverRegisterView> createState() => _DriverRegisterViewState();
}

class _DriverRegisterViewState extends State<DriverRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carPlateController = TextEditingController();
  final _pricePerKmController = TextEditingController();

  @override
  void dispose() {
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بيانات السائق المركبة',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoalBlack,
                ),
              ),
              SizedBox(height: 16.h),

              // Name
              Text('الاسم الكامل', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null,
                decoration: const InputDecoration(hintText: 'الكابتن محمد'),
              ),
              SizedBox(height: 16.h),

              // Phone
              Text('رقم الهاتف', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null,
                decoration: const InputDecoration(hintText: '5xxxxxxxx'),
              ),
              SizedBox(height: 24.h),

              Text(
                'بيانات السيارة والتسعير',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoalBlack,
                ),
              ),
              SizedBox(height: 16.h),

              // Car Model
              Text('نوع وموديل السيارة', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _carModelController,
                validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null,
                decoration: const InputDecoration(hintText: 'تويوتا كامري 2023'),
              ),
              SizedBox(height: 16.h),

              // Car Plate
              Text('رقم اللوحة', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _carPlateController,
                validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null,
                decoration: const InputDecoration(hintText: 'أ ب ج 1234'),
              ),
              SizedBox(height: 16.h),

              // Price per KM (Driver sets his own price)
              Text('سعر الكيلو (ر.ي)', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _pricePerKmController,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'حقل مطلوب' : null,
                decoration: const InputDecoration(hintText: '500'),
              ),
              SizedBox(height: 36.h),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Submit Driver registration
                  }
                },
                child: const Text('إتمام التسجيل ورفع المستندات'),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}