// lib/features/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../theme/app_theme.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _mapController;
  
  // Default camera position (Example coordinates, can be updated via LocationService later)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(15.369445, 44.191007), // Example: Sana'a coordinates
    zoom: 15.0,
  );

  bool _isSearchingDestination = false;
  final TextEditingController _pickupController = TextEditingController(text: 'موقعي الحالي');
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map Background
          GoogleMap(
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),

          // 2. Top Header & Menu / Profile Bar
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile / Menu Button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.charcoalBlack.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: AppTheme.charcoalBlack),
                    onPressed: () {
                      // TODO: Open Drawer or Profile
                    },
                  ),
                ),
                // App Brand Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.charcoalBlack.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Rahal Taxi',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.deepBurgundy,
                    ),
                  ),
                ),
                // Notifications Button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.charcoalBlack.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppTheme.charcoalBlack),
                    onPressed: () {
                      // TODO: Open Notifications
                    },
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Action Buttons (Location Reset)
          Positioned(
            bottom: 240.h,
            right: 20.w,
            child: FloatingActionButton(
              heroTag: 'current_location_btn',
              backgroundColor: AppTheme.pureWhite,
              elevation: 4,
              onPressed: () {
                // TODO: Animate camera to current location
              },
              child: const Icon(Icons.my_location, color: AppTheme.deepBurgundy),
            ),
          ),

          // 4. Bottom Sheet for Ride Booking & Destination Selection
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppTheme.creamBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoalBlack.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicator Bar
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    'إلى أين تريد الذهاب؟',
                    style: GoogleFonts.cairo(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoalBlack,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Destination Input Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearchingDestination = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppTheme.lightGrey),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppTheme.deepBurgundy),
                          SizedBox(width: 12.w),
                          Text(
                            'ابحث عن وجهتك القادمة...',
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Quick Destination Suggestions (e.g., Home, Work)
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickDestinationChip(
                          icon: Icons.home_outlined,
                          title: 'المنزل',
                          subtitle: 'إضافة عنوان المنزل',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildQuickDestinationChip(
                          icon: Icons.work_outline,
                          title: 'العمل',
                          subtitle: 'إضافة عنوان العمل',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDestinationChip({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.creamBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.deepBurgundy, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: AppTheme.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}