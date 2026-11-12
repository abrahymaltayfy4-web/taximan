import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'result.dart';

/// يحوّل أخطاء Firebase/Network إلى Failure مجالية
class ErrorMapper {
  const ErrorMapper._();

  /// تحويل أي exception إلى Failure
  static Failure mapException(Object error, [StackTrace? stack]) {
    // ─── Firebase Auth ───
    if (error is FirebaseAuthException) {
      return _mapAuthError(error);
    }

    // ─── Firestore ───
    if (error is FirebaseException) {
      return _mapFirestoreError(error);
    }

    // ─── شبكة ───
    if (error is SocketException || error is HttpException) {
      return NetworkFailure('Network error: ${error.runtimeType}', error);
    }

    // ─── Timeout ───
    if (error is TimeoutException) {
      return TimeoutFailure('Request timed out', error);
    }

    // ─── رسائل نصية مخصصة (من throw Exception('...')) ───
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('محظور') || msg.contains('blocked')) {
        return const BlockedAccountFailure();
      }
      if (msg.contains('قيد المراجعة') || msg.contains('pending')) {
        return const PendingApprovalFailure();
      }
      if (msg.contains('غير موجود') || msg.contains('not found')) {
        return const RideNotFoundFailure();
      }
      if (msg.contains('مقبولة مسبقاً') || msg.contains('already accepted')) {
        return const RideAlreadyAcceptedFailure();
      }
    }

    return UnknownFailure('Unexpected: ${error.runtimeType}', error);
  }

  static Failure _mapAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' || 'wrong-password' || 'invalid-credential' =>
        const AuthFailure(ErrorCode.invalidCredentials, 'Invalid credentials'),
      'email-already-in-use' => const AuthFailure(
        ErrorCode.emailAlreadyInUse,
        'Email already in use',
      ),
      'weak-password' => const AuthFailure(
        ErrorCode.weakPassword,
        'Weak password',
      ),
      'user-disabled' => const DisabledAccountFailure(
        'Account disabled by admin',
      ),
      'network-request-failed' => NetworkFailure('Auth network error', e),
      'too-many-requests' => const AuthFailure(
        ErrorCode.unauthenticated,
        'Too many attempts',
      ),
      _ => AuthFailure(ErrorCode.unauthenticated, 'Auth error: ${e.code}', e),
    };
  }

  static Failure _mapFirestoreError(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' => PermissionFailure(
        'Firestore permission denied',
        e,
      ),
      'not-found' => const RideNotFoundFailure('Document not found'),
      'unavailable' => NetworkFailure('Firestore unavailable', e),
      'aborted' || 'failed-precondition' => TransactionFailure(
        ErrorCode.transactionFailed,
        'Transaction conflict: ${e.code}',
        e,
      ),
      'deadline-exceeded' => TimeoutFailure('Firestore timeout', e),
      'already-exists' => const TransactionFailure(
        ErrorCode.duplicateTransaction,
        'Document already exists',
      ),
      _ => ServerFailure('Firestore error: ${e.code}', e),
    };
  }
}

/// تنفيذ آمن مع التقاط الأخطاء
Future<Result<T>> safeCall<T>(Future<T> Function() action) async {
  try {
    final result = await action();
    return Result.success(result);
  } catch (e, stack) {
    return Result.failure(ErrorMapper.mapException(e, stack));
  }
}
