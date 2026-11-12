/// ═══════════════════════════════════════════
/// Result<T> — نتيجة عملية (نجاح أو فشل)
/// ═══════════════════════════════════════════
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(Failure failure) = Err<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success<T>(data: final d) => success(d),
      Err<T>(failure: final f) => failure(f),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Err<T>;
  T get data => (this as Success<T>).data;
  Failure get failure => (this as Err<T>).failure;
}

final class Success<T> extends Result<T> {
  @override
  final T data;
  const Success(this.data);
}

final class Err<T> extends Result<T> {
  @override
  final Failure failure;
  const Err(this.failure);
}

/// ═══════════════════════════════════════════
/// ErrorCode — رمز خطأ ثابت ومستقل عن اللغة
/// ═══════════════════════════════════════════
enum ErrorCode {
  // شبكة
  networkUnavailable,
  timeout,
  // مصادقة
  unauthenticated,
  invalidCredentials,
  emailAlreadyInUse,
  weakPassword,
  // صلاحيات
  permissionDenied,
  // حساب
  accountBlocked,
  accountDisabled,
  accountPendingApproval,
  accountRejected,
  accountNotFound,
  // رحلة
  rideNotFound,
  rideAlreadyAccepted,
  rideCannotCancel,
  // معاملات
  transactionFailed,
  duplicateTransaction,
  insufficientBalance,
  // إشعارات
  notificationFailed,
  invalidFcmToken,
  // عام
  validationError,
  serverError,
  unknown,
}

/// ═══════════════════════════════════════════
/// Failure — خطأ مجال (Domain Error)
/// message: رسالة تقنية للـ logging (بالإنجليزية)
/// code: رمز خطأ ثابت
/// cause: الخطأ الأصلي (للتتبع)
/// ═══════════════════════════════════════════
sealed class Failure {
  final ErrorCode code;
  final String message;
  final Object? cause;
  const Failure(this.code, this.message, {this.cause});

  @override
  String toString() => '${code.name}: $message';
}

// ─── شبكة ───
final class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network unavailable', Object? cause])
    : super(ErrorCode.networkUnavailable, message, cause: cause);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'Request timed out', Object? cause])
    : super(ErrorCode.timeout, message, cause: cause);
}

// ─── مصادقة ───
final class AuthFailure extends Failure {
  const AuthFailure([
    ErrorCode code = ErrorCode.unauthenticated,
    String message = 'Authentication error',
    Object? cause,
  ]) : super(code, message, cause: cause);
}

// ─── صلاحيات ───
final class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied', Object? cause])
    : super(ErrorCode.permissionDenied, message, cause: cause);
}

// ─── حساب ───
final class AccountFailure extends Failure {
  const AccountFailure(
    ErrorCode code, [
    String message = 'Account error',
    Object? cause,
  ]) : super(code, message, cause: cause);
}

final class BlockedAccountFailure extends AccountFailure {
  const BlockedAccountFailure([String message = 'Account is blocked'])
    : super(ErrorCode.accountBlocked, message);
}

final class DisabledAccountFailure extends AccountFailure {
  const DisabledAccountFailure([String message = 'Account is disabled'])
    : super(ErrorCode.accountDisabled, message);
}

final class PendingApprovalFailure extends AccountFailure {
  const PendingApprovalFailure([String message = 'Account pending approval'])
    : super(ErrorCode.accountPendingApproval, message);
}

final class RejectedAccountFailure extends AccountFailure {
  const RejectedAccountFailure([String message = 'Account rejected'])
    : super(ErrorCode.accountRejected, message);
}

final class AccountNotFoundFailure extends AccountFailure {
  const AccountNotFoundFailure([String message = 'Account not found'])
    : super(ErrorCode.accountNotFound, message);
}

// ─── رحلة ───
final class RideNotFoundFailure extends Failure {
  const RideNotFoundFailure([String message = 'Ride not found'])
    : super(ErrorCode.rideNotFound, message);
}

final class RideAlreadyAcceptedFailure extends Failure {
  const RideAlreadyAcceptedFailure([String message = 'Ride already accepted'])
    : super(ErrorCode.rideAlreadyAccepted, message);
}

final class RideCannotCancelFailure extends Failure {
  const RideCannotCancelFailure([
    String message = 'Ride cannot be cancelled in current state',
  ]) : super(ErrorCode.rideCannotCancel, message);
}

// ─── معاملات مالية ───
final class TransactionFailure extends Failure {
  const TransactionFailure([
    ErrorCode code = ErrorCode.transactionFailed,
    String message = 'Transaction failed',
    Object? cause,
  ]) : super(code, message, cause: cause);
}

// ─── إشعارات ───
final class NotificationFailure extends Failure {
  const NotificationFailure([
    String message = 'Notification failed',
    Object? cause,
  ]) : super(ErrorCode.notificationFailed, message, cause: cause);
}

// ─── عام ───
final class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error'])
    : super(ErrorCode.validationError, message);
}

final class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error', Object? cause])
    : super(ErrorCode.serverError, message, cause: cause);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Unknown error', Object? cause])
    : super(ErrorCode.unknown, message, cause: cause);
}
