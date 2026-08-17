import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../cubit/profile_cubit.dart';
import '../repositories/profile_repository.dart';
import '../services/profile_service.dart';

class CaptainProfileView extends StatefulWidget {
  const CaptainProfileView({super.key});

  @override
  State<CaptainProfileView> createState() => _CaptainProfileViewState();
}

class _CaptainProfileViewState extends State<CaptainProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carPlateController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _carModelController.dispose();
    _carPlateController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(ProfileRepository(ProfileService()))..loadProfile(),
      child: Scaffold(
        backgroundColor: AppTheme.creamBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.deepBurgundy,
          title: Text('الملف الشخصي', style: GoogleFonts.cairo(color: AppTheme.pureWhite, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.pureWhite),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح', style: GoogleFonts.cairo())),
                );
              } else if (state is ProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message, style: GoogleFonts.cairo())),
                );
              } else if (state is ProfileLoaded) {
                _nameController.text = state.driver.name;
                _phoneController.text = state.driver.phone;
                _carModelController.text = state.driver.carModel;
                _carPlateController.text = state.driver.carPlate;
                _priceController.text = state.driver.pricePerKm.toString();
              }
            },
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.deepBurgundy));
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: AppTheme.lightGrey,
                        child: Icon(Icons.person, size: 60.r, color: AppTheme.deepBurgundy),
                      ),
                      SizedBox(height: 32.h),
                      _buildTextField('الاسم', _nameController, Icons.person),
                      SizedBox(height: 16.h),
                      _buildTextField('رقم الهاتف', _phoneController, Icons.phone, TextInputType.phone),
                      SizedBox(height: 16.h),
                      _buildTextField('موديل السيارة', _carModelController, Icons.directions_car),
                      SizedBox(height: 16.h),
                      _buildTextField('لوحة السيارة', _carPlateController, Icons.payment),
                      SizedBox(height: 16.h),
                      _buildTextField('سعر الكيلومتر (ريال)', _priceController, Icons.attach_money, const TextInputType.numberWithOptions(decimal: true)),
                      SizedBox(height: 32.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.deepBurgundy,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          onPressed: state is ProfileUpdating
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<ProfileCubit>().updateProfile(
                                          name: _nameController.text,
                                          phone: _phoneController.text,
                                          carModel: _carModelController.text,
                                          carPlate: _carPlateController.text,
                                          pricePerKm: double.tryParse(_priceController.text) ?? 0.0,
                                        );
                                  }
                                },
                          child: state is ProfileUpdating
                              ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: AppTheme.pureWhite))
                              : Text('حفظ التعديلات', style: GoogleFonts.cairo(color: AppTheme.pureWhite, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        ),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, [TextInputType type = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: GoogleFonts.cairo(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: AppTheme.darkGrey),
        prefixIcon: Icon(icon, color: AppTheme.deepBurgundy),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.deepBurgundy),
        ),
        filled: true,
        fillColor: AppTheme.pureWhite,
      ),
      validator: (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }
}
