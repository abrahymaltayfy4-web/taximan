import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/skeletons/skeletons.dart';
import '../cubit/session_cubit.dart';
import '../cubit/session_state.dart';

/// بوابة الجلسة — تعتمد كلياً على SessionCubit (عرض فقط)
class SessionGate extends StatelessWidget {
  final WidgetBuilder authenticatedBuilder;
  final WidgetBuilder unauthenticatedBuilder;

  const SessionGate({
    super.key,
    required this.authenticatedBuilder,
    required this.unauthenticatedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionCubit, SessionState>(
      listener: (context, state) {
        // إظهار رسائل الحظر/الرفض
        if (state is SessionBlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.status.userMessage),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SessionRejected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفض طلب تسجيلك. تواصل مع الإدارة.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return switch (state) {
          SessionInitial() || SessionLoading() => const Scaffold(
            backgroundColor: AppTheme.creamBackground,
            body: SessionSkeleton(),
          ),
          SessionAuthenticated() => authenticatedBuilder(context),
          SessionPendingApproval() => const Scaffold(
            backgroundColor: AppTheme.creamBackground,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'حسابك قيد المراجعة. سيتم إعلامك عند الموافقة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          _ => unauthenticatedBuilder(context),
        };
      },
    );
  }
}
