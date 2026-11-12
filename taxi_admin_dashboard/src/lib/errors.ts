/**
 * ═══════════════════════════════════════════
 * نموذج الأخطاء الموحد — Admin Dashboard
 * ═══════════════════════════════════════════
 */

export const ErrorCode = {
  // شبكة
  NETWORK_UNAVAILABLE: 'network_unavailable',
  TIMEOUT: 'timeout',
  // مصادقة
  UNAUTHENTICATED: 'unauthenticated',
  INVALID_CREDENTIALS: 'invalid_credentials',
  // صلاحيات
  PERMISSION_DENIED: 'permission_denied',
  // حساب
  ACCOUNT_BLOCKED: 'account_blocked',
  ACCOUNT_DISABLED: 'account_disabled',
  ACCOUNT_NOT_FOUND: 'account_not_found',
  // رحلة
  RIDE_NOT_FOUND: 'ride_not_found',
  RIDE_ALREADY_ACCEPTED: 'ride_already_accepted',
  // معاملات
  TRANSACTION_FAILED: 'transaction_failed',
  DUPLICATE_TRANSACTION: 'duplicate_transaction',
  // إشعارات
  NOTIFICATION_FAILED: 'notification_failed',
  INVALID_FCM_TOKEN: 'invalid_fcm_token',
  // عام
  VALIDATION_ERROR: 'validation_error',
  RATE_LIMITED: 'rate_limited',
  SERVER_ERROR: 'server_error',
  UNKNOWN: 'unknown',
} as const;

export type ErrorCodeType = typeof ErrorCode[keyof typeof ErrorCode];

export interface AppError {
  code: ErrorCodeType;
  message: string; // رسالة تقنية (إنجليزية)
  userMessage: string; // رسالة عربية للمستخدم
}

/** رسائل عربية لكل ErrorCode */
const ARABIC_MESSAGES: Record<ErrorCodeType, string> = {
  network_unavailable: 'لا يوجد اتصال بالإنترنت',
  timeout: 'انتهت المهلة. حاول مرة أخرى',
  unauthenticated: 'يجب تسجيل الدخول',
  invalid_credentials: 'البريد أو كلمة المرور غير صحيحة',
  permission_denied: 'ليس لديك صلاحية لهذا الإجراء',
  account_blocked: 'الحساب محظور',
  account_disabled: 'الحساب معطّل',
  account_not_found: 'الحساب غير موجود',
  ride_not_found: 'الرحلة غير موجودة',
  ride_already_accepted: 'الرحلة لم تعد متاحة',
  transaction_failed: 'فشلت العملية المالية',
  duplicate_transaction: 'تم تنفيذ هذه العملية مسبقاً',
  notification_failed: 'فشل إرسال الإشعار',
  invalid_fcm_token: 'الجهاز غير مسجل للإشعارات',
  validation_error: 'البيانات المدخلة غير صحيحة',
  rate_limited: 'طلبات كثيرة. حاول بعد دقيقة',
  server_error: 'خطأ في الخادم. حاول لاحقاً',
  unknown: 'حدث خطأ غير متوقع',
};

/** إنشاء AppError */
export function createAppError(code: ErrorCodeType, technicalMessage?: string): AppError {
  return {
    code,
    message: technicalMessage || code,
    userMessage: ARABIC_MESSAGES[code] || ARABIC_MESSAGES.unknown,
  };
}

/** استخراج رسالة عربية من API response */
export function getErrorMessage(error: unknown): string {
  if (error && typeof error === 'object' && 'code' in error) {
    const code = (error as { code: string }).code as ErrorCodeType;
    return ARABIC_MESSAGES[code] || ARABIC_MESSAGES.unknown;
  }
  if (error instanceof Error) {
    // لا نعرض الخطأ التقني للمستخدم
    return ARABIC_MESSAGES.unknown;
  }
  return ARABIC_MESSAGES.unknown;
}
