import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_theme.dart';
import '../cubit/customer_profile_cubit.dart';
import '../repositories/customer_profile_repository.dart';
import '../services/customer_profile_service.dart';
import '../../ride_history/views/ride_history_view.dart';
import '../../auth/views/login_view.dart';

class CustomerProfileView extends StatelessWidget {
  const CustomerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerProfileCubit(CustomerProfileRepository(CustomerProfileService()))..loadProfile(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppTheme.creamBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.deepBurgundy,
            elevation: 0,
            title: Text(
              'الملف الشخصي',
              style: GoogleFonts.cairo(
                color: AppTheme.pureWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.pureWhite),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: BlocConsumer<CustomerProfileCubit, CustomerProfileState>(
            listener: (context, state) {
              if (state is CustomerProfileUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تحديث البيانات بنجاح', style: GoogleFonts.cairo()),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is CustomerProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: GoogleFonts.cairo()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is CustomerProfileLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.deepBurgundy),
                );
              }

              if (state is CustomerProfileLoaded) {
                return _ProfileContent(
                  name: state.name,
                  email: state.email,
                  phone: state.phone,
                );
              }

              if (state is CustomerProfileUpdating) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.deepBurgundy),
                      SizedBox(height: 16),
                      Text('جاري التحديث...'),
                    ],
                  ),
                );
              }

              return const Center(
                child: CircularProgressIndicator(color: AppTheme.deepBurgundy),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final String name;
  final String email;
  final String phone;

  const _ProfileContent({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
  }

  @override
  void didUpdateWidget(covariant _ProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) {
      _nameController.text = widget.name;
    }
    if (oldWidget.phone != widget.phone) {
      _phoneController.text = widget.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // ===== صورة البروفايل =====
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoalBlack.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppTheme.deepBurgundy.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person,
                      size: 50.sp,
                      color: AppTheme.deepBurgundy,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    widget.name,
                    style: GoogleFonts.cairo(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoalBlack,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.email,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ===== بيانات الحساب =====
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoalBlack.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'بيانات الحساب',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.charcoalBlack,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                        },
                        icon: Icon(
                          _isEditing ? Icons.close : Icons.edit_outlined,
                          color: AppTheme.deepBurgundy,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // الاسم
                  _buildField(
                    icon: Icons.person_outline,
                    label: 'الاسم',
                    controller: _nameController,
                    enabled: _isEditing,
                    validator: (v) => v!.isEmpty ? 'يرجى إدخال الاسم' : null,
                  ),
                  SizedBox(height: 16.h),

                  // البريد الإلكتروني (غير قابل للتعديل)
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'البريد الإلكتروني',
                    value: widget.email,
                  ),
                  SizedBox(height: 16.h),

                  // رقم الهاتف
                  _buildField(
                    icon: Icons.phone_outlined,
                    label: 'رقم الهاتف',
                    controller: _phoneController,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'يرجى إدخال رقم الهاتف' : null,
                  ),

                  if (_isEditing) ...[
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<CustomerProfileCubit>().updateProfile(
                                  name: _nameController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                );
                            setState(() => _isEditing = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.deepBurgundy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'حفظ التغييرات',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.pureWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ===== قائمة الخيارات =====
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoalBlack.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildOptionTile(
                    icon: Icons.history,
                    title: 'سجل الرحلات',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RideHistoryView()),
                      );
                    },
                  ),
                  Divider(height: 1, color: AppTheme.lightGrey, indent: 60.w),
                  _buildOptionTile(
                    icon: Icons.help_outline,
                    title: 'المساعدة والدعم',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // ===== زر تسجيل الخروج =====
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginView()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'تسجيل الخروج',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.cairo(
        fontSize: 15.sp,
        color: AppTheme.charcoalBlack,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(
          fontSize: 13.sp,
          color: AppTheme.darkGrey,
        ),
        prefixIcon: Icon(icon, color: AppTheme.deepBurgundy, size: 22.sp),
        filled: true,
        fillColor: enabled ? AppTheme.creamBackground : AppTheme.lightGrey.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.lightGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppTheme.deepBurgundy, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.deepBurgundy, size: 22.sp),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  color: AppTheme.darkGrey,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppTheme.charcoalBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppTheme.deepBurgundy.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.deepBurgundy, size: 22.sp),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.charcoalBlack,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.darkGrey),
      onTap: onTap,
    );
  }
}