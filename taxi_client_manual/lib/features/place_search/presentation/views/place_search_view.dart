import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/place_details.dart';
import '../cubit/place_search_cubit.dart';
import '../cubit/place_search_state.dart';

/// شاشة البحث عن الأماكن — تُعرض كـ FullScreen overlay
/// تُرجع [PlaceDetails] عند اختيار مكان، أو null عند الإلغاء
class PlaceSearchView extends StatefulWidget {
  /// نوع الحقل: pickup أو destination
  final String fieldType;

  const PlaceSearchView({
    super.key,
    this.fieldType = 'destination',
  });

  @override
  State<PlaceSearchView> createState() => _PlaceSearchViewState();
}

class _PlaceSearchViewState extends State<PlaceSearchView> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();

    // فتح لوحة المفاتيح تلقائياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.creamBackground,
        body: SafeArea(
          child: Column(
            children: [
              // ═══ شريط البحث ═══
              _buildSearchBar(context),

              // ═══ قائمة النتائج ═══
              Expanded(
                child: BlocConsumer<PlaceSearchCubit, PlaceSearchState>(
                  listener: (context, state) {
                    if (state is PlaceDetailsLoaded) {
                      // إرجاع التفاصيل للصفحة الرئيسية
                      Navigator.of(context).pop(state.details);
                    } else if (state is PlaceDetailsError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.message,
                            style: GoogleFonts.cairo(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is PlaceSearchInitial) {
                      return _buildInitialHint();
                    }
                    if (state is PlaceSearchLoading) {
                      return _buildLoadingSkeleton();
                    }
                    if (state is PlaceSearchEmpty) {
                      return _buildEmptyState(state.query);
                    }
                    if (state is PlaceSearchError) {
                      return _buildErrorState(state.message);
                    }
                    if (state is PlaceDetailsLoading) {
                      return _buildDetailsLoading();
                    }
                    if (state is PlaceSearchLoaded) {
                      return _buildSuggestionsList(context, state);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // شريط البحث
  // ═══════════════════════════════════════════

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.charcoalBlack.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر الرجوع
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.creamBackground,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.charcoalBlack,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // حقل البحث
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (value) {
                context.read<PlaceSearchCubit>().onQueryChanged(value);
              },
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                color: AppTheme.charcoalBlack,
              ),
              decoration: InputDecoration(
                hintText: widget.fieldType == 'pickup'
                    ? 'ابحث عن نقطة الانطلاق...'
                    : 'ابحث عن وجهتك...',
                hintStyle: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: AppTheme.darkGrey.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.deepBurgundy,
                  size: 22.sp,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          context.read<PlaceSearchCubit>().clearSearch();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close_rounded,
                          color: AppTheme.darkGrey,
                          size: 20.sp,
                        ),
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.creamBackground,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: AppTheme.deepBurgundy.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // الحالة الأولية — تلميحات
  // ═══════════════════════════════════════════

  Widget _buildInitialHint() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64.sp,
              color: AppTheme.lightGrey,
            ),
            SizedBox(height: 16.h),
            Text(
              'ابحث عن مكان أو عنوان',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                color: AppTheme.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'اكتب اسم المكان أو الشارع أو المنطقة',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: AppTheme.darkGrey.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // حالة التحميل — Skeleton
  // ═══════════════════════════════════════════

  Widget _buildLoadingSkeleton() {
    return Semantics(
      label: 'جاري البحث',
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Semantics(
            hidden: true,
            child: Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  // أيقونة skeleton
                  _SkeletonBox(
                    width: 36.w,
                    height: 36.w,
                    borderRadius: 10.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(
                          width: 160.w,
                          height: 14.h,
                          borderRadius: 4.r,
                        ),
                        SizedBox(height: 8.h),
                        _SkeletonBox(
                          width: 220.w,
                          height: 10.h,
                          borderRadius: 4.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════
  // حالة عدم وجود نتائج
  // ═══════════════════════════════════════════

  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 56.sp,
              color: AppTheme.lightGrey,
            ),
            SizedBox(height: 16.h),
            Text(
              'لم يتم العثور على نتائج',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                color: AppTheme.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'جرّب كلمات بحث مختلفة لـ "$query"',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: AppTheme.darkGrey.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // حالة الخطأ
  // ═══════════════════════════════════════════

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56.sp,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ أثناء البحث',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                color: AppTheme.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
              style: GoogleFonts.cairo(
                fontSize: 13.sp,
                color: AppTheme.darkGrey.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // تحميل تفاصيل المكان
  // ═══════════════════════════════════════════

  Widget _buildDetailsLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.deepBurgundy,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // قائمة الاقتراحات
  // ═══════════════════════════════════════════

  Widget _buildSuggestionsList(
    BuildContext context,
    PlaceSearchLoaded state,
  ) {
    return Semantics(
      label: 'نتائج البحث: ${state.suggestions.length} نتيجة',
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        itemCount: state.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = state.suggestions[index];

          return GestureDetector(
            onTap: () {
              context.read<PlaceSearchCubit>().selectPlace(
                    suggestion.placeId,
                  );
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color:
                        AppTheme.charcoalBlack.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // أيقونة المكان
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppTheme.deepBurgundy.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.deepBurgundy,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // تفاصيل المكان
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.mainText,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.charcoalBlack,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (suggestion.secondaryText.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            suggestion.secondaryText,
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: AppTheme.darkGrey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // سهم
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.lightGrey,
                    size: 14.sp,
                  ),
                ],
              ),
            ),
          ).animate(
            delay: (index < 8 ? index * 80 : 0).ms,
          ).fadeIn(
            duration: 300.ms,
          ).slideY(
            begin: 0.2,
            duration: 300.ms,
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════
// Skeleton Box — مربع رمادي مع shimmer
// ═══════════════════════════════════════════

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    Widget box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.lightGrey.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (disableAnimations) return box;

    return box
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .shimmer(
          duration: 1200.ms,
          color: AppTheme.pureWhite.withValues(alpha: 0.4),
        );
  }
}
