import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'location_access_cubit.dart';
import 'location_service.dart';

/// حوار شرح مشكلة صلاحية/خدمة الموقع — مشترك بين تطبيقي العميل والكابتن.
/// يتطلب [LocationAccessCubit] في الـ context.
void showLocationAccessDialog(
  BuildContext context,
  LocationAccessStatus status,
) {
  final (String title, String message, bool openSettings, bool openAppSettings) =
      switch (status) {
        LocationAccessStatus.serviceDisabled => (
          'خدمة الموقع مغلقة',
          'يرجى تفعيل خدمة الموقع (GPS) لاستخدام التطبيق',
          true,
          false,
        ),
        LocationAccessStatus.denied => (
          'صلاحية الموقع مرفوضة',
          'يجب السماح بصلاحية الموقع لاستخدام التطبيق',
          false,
          false,
        ),
        LocationAccessStatus.deniedForever => (
          'صلاحية الموقع مرفوضة نهائياً',
          'يرجى الذهاب إلى إعدادات التطبيق وتفعيل صلاحية الموقع',
          false,
          true,
        ),
        LocationAccessStatus.granted => ('', '', false, false),
      };
  if (status == LocationAccessStatus.granted) return;

  final locationCubit = context.read<LocationAccessCubit>();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: GoogleFonts.cairo()),
        actions: [
          if (openSettings)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                locationCubit.openSettings(appSettings: false);
              },
              child: Text(
                'فتح الإعدادات',
                style: GoogleFonts.cairo(color: AppTheme.deepBurgundy),
              ),
            ),
          if (openAppSettings)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                locationCubit.openSettings(appSettings: true);
              },
              child: Text(
                'إعدادات التطبيق',
                style: GoogleFonts.cairo(color: AppTheme.deepBurgundy),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              locationCubit.check();
            },
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.cairo(color: AppTheme.deepBurgundy),
            ),
          ),
        ],
      ),
    ),
  );
}
