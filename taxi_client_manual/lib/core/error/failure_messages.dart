import 'result.dart';

/// ترجمة ErrorCode إلى رسالة عربية للعرض في الواجهة فقط.
/// لا يُستخدم في Domain أو Data.
class FailureMessages {
  const FailureMessages._();

  static String arabicMessage(Failure failure) {
    return switch (failure.code) {
      // شبكة
      ErrorCode.networkUnavailable => 'لا يوجد اتصال بالإنترنت',
      ErrorCode.timeout => 'انتهت المهلة. حاول مرة أخرى',
      // مصادقة
      ErrorCode.unauthenticated => 'يجب تسجيل الدخول',
      ErrorCode.invalidCredentials =>
        'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      ErrorCode.emailAlreadyInUse => 'هذا البريد مسجل مسبقاً',
      ErrorCode.weakPassword => 'كلمة المرور ضعيفة. استخدم 6 أحرف على الأقل',
      // صلاحيات
      ErrorCode.permissionDenied => 'ليس لديك صلاحية لهذا الإجراء',
      // حساب
      ErrorCode.accountBlocked => 'حسابك محظور. تواصل مع الإدارة',
      ErrorCode.accountDisabled => 'حسابك معطّل. تواصل مع الإدارة',
      ErrorCode.accountPendingApproval =>
        'حسابك قيد المراجعة. سيتم إشعارك عند الموافقة',
      ErrorCode.accountRejected => 'تم رفض طلب التسجيل. تواصل مع الإدارة',
      ErrorCode.accountNotFound => 'الحساب غير موجود',
      // رحلة
      ErrorCode.rideNotFound => 'الرحلة غير موجودة',
      ErrorCode.rideAlreadyAccepted => 'عذراً، هذه الرحلة لم تعد متاحة',
      ErrorCode.rideCannotCancel => 'لا يمكن إلغاء الرحلة في حالتها الحالية',
      // معاملات
      ErrorCode.transactionFailed => 'فشلت العملية المالية. حاول مرة أخرى',
      ErrorCode.duplicateTransaction => 'تم تنفيذ هذه العملية مسبقاً',
      ErrorCode.insufficientBalance => 'رصيد غير كافي',
      // إشعارات
      ErrorCode.notificationFailed => 'فشل إرسال الإشعار',
      ErrorCode.invalidFcmToken => 'الجهاز غير مسجل لاستقبال الإشعارات',
      // عام
      ErrorCode.validationError => 'البيانات المدخلة غير صحيحة',
      ErrorCode.serverError => 'خطأ في الخادم. حاول لاحقاً',
      ErrorCode.unknown => 'حدث خطأ غير متوقع',
    };
  }
}
