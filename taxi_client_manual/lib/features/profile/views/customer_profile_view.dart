// lib/features/profile/views/customer_profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class CustomerProfileView extends StatelessWidget {
  const CustomerProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.charcoalBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoalBlack.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36.r,
                    backgroundColor: AppTheme.lightGrey,
                    child: const Icon(Icons.person, size: 40, color: AppTheme.darkGrey),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'محمد أحمد',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.charcoalBlack,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'mohamed@example.com',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Profile Options List
            _buildProfileOption(
              icon: Icons.history,
              title: 'سجل الرحلات',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.payment_outlined,
              title: 'طرق الدفع',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.notifications_outlined,
              title: 'الإشعارات',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.help_outline,
              title: 'المساعدة والدعم',
              onTap: () {},
            ),
            SizedBox(height: 24.h),

            // Logout Button
            ElevatedButton(
              onPressed: () {
                // TODO: Logout logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBurgundy,
              ),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.creamBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.deepBurgundy, size: 20.sp),
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
      ),
    );
  }
}