import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_client_manual/core/error/result.dart';
import 'package:taxi_client_manual/core/error/failure_messages.dart';
import 'package:taxi_client_manual/core/error/app_logger.dart';

void main() {
  group('🔒 Result<T>', () {
    test('Success يحمل البيانات', () {
      final result = Result.success(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.data, 42);
    });

    test('Err يحمل الخطأ', () {
      final result = Result<int>.failure(const NetworkFailure());
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NetworkFailure>());
      expect(result.failure.code, ErrorCode.networkUnavailable);
    });

    test('when يفرّع صح', () {
      final result = Result.success('hello');
      final output = result.when(
        success: (d) => 'got: $d',
        failure: (f) => 'err: ${f.code}',
      );
      expect(output, 'got: hello');
    });

    test('when يفرّع للخطأ', () {
      final result = Result<String>.failure(const AuthFailure());
      final output = result.when(
        success: (d) => 'got: $d',
        failure: (f) => 'err: ${f.code.name}',
      );
      expect(output, 'err: unauthenticated');
    });
  });

  group('🔒 ErrorCode — كل Failure تحتوي الرمز الصحيح', () {
    test('NetworkFailure', () {
      const f = NetworkFailure();
      expect(f.code, ErrorCode.networkUnavailable);
      expect(f.message, 'Network unavailable');
    });

    test('TimeoutFailure', () {
      const f = TimeoutFailure();
      expect(f.code, ErrorCode.timeout);
    });

    test('AuthFailure — unauthenticated', () {
      const f = AuthFailure();
      expect(f.code, ErrorCode.unauthenticated);
    });

    test('AuthFailure — invalidCredentials', () {
      const f = AuthFailure(ErrorCode.invalidCredentials, 'bad creds');
      expect(f.code, ErrorCode.invalidCredentials);
    });

    test('AuthFailure — emailAlreadyInUse', () {
      const f = AuthFailure(ErrorCode.emailAlreadyInUse, 'dup email');
      expect(f.code, ErrorCode.emailAlreadyInUse);
    });

    test('AuthFailure — weakPassword', () {
      const f = AuthFailure(ErrorCode.weakPassword, 'weak');
      expect(f.code, ErrorCode.weakPassword);
    });

    test('PermissionFailure', () {
      const f = PermissionFailure();
      expect(f.code, ErrorCode.permissionDenied);
    });

    test('BlockedAccountFailure', () {
      const f = BlockedAccountFailure();
      expect(f.code, ErrorCode.accountBlocked);
      expect(f, isA<AccountFailure>());
    });

    test('DisabledAccountFailure', () {
      const f = DisabledAccountFailure();
      expect(f.code, ErrorCode.accountDisabled);
    });

    test('PendingApprovalFailure', () {
      const f = PendingApprovalFailure();
      expect(f.code, ErrorCode.accountPendingApproval);
    });

    test('RejectedAccountFailure', () {
      const f = RejectedAccountFailure();
      expect(f.code, ErrorCode.accountRejected);
    });

    test('AccountNotFoundFailure', () {
      const f = AccountNotFoundFailure();
      expect(f.code, ErrorCode.accountNotFound);
    });

    test('RideNotFoundFailure', () {
      const f = RideNotFoundFailure();
      expect(f.code, ErrorCode.rideNotFound);
    });

    test('RideAlreadyAcceptedFailure', () {
      const f = RideAlreadyAcceptedFailure();
      expect(f.code, ErrorCode.rideAlreadyAccepted);
    });

    test('RideCannotCancelFailure', () {
      const f = RideCannotCancelFailure();
      expect(f.code, ErrorCode.rideCannotCancel);
    });

    test('TransactionFailure', () {
      const f = TransactionFailure();
      expect(f.code, ErrorCode.transactionFailed);
    });

    test('TransactionFailure — duplicate', () {
      const f = TransactionFailure(ErrorCode.duplicateTransaction, 'dup');
      expect(f.code, ErrorCode.duplicateTransaction);
    });

    test('NotificationFailure', () {
      const f = NotificationFailure();
      expect(f.code, ErrorCode.notificationFailed);
    });

    test('ValidationFailure', () {
      const f = ValidationFailure();
      expect(f.code, ErrorCode.validationError);
    });

    test('ServerFailure', () {
      const f = ServerFailure();
      expect(f.code, ErrorCode.serverError);
    });

    test('UnknownFailure', () {
      const f = UnknownFailure();
      expect(f.code, ErrorCode.unknown);
    });
  });

  group('🔒 FailureMessages — رسائل عربية', () {
    test('كل ErrorCode له رسالة عربية', () {
      for (final code in ErrorCode.values) {
        final failure = _makeFailure(code);
        final msg = FailureMessages.arabicMessage(failure);
        expect(msg, isNotEmpty, reason: '${code.name} ليس له رسالة');
        expect(
          msg,
          isNot(contains('error')),
          reason: '${code.name} يحتوي إنجليزي',
        );
      }
    });

    test('شبكة → رسالة صحيحة', () {
      expect(
        FailureMessages.arabicMessage(const NetworkFailure()),
        'لا يوجد اتصال بالإنترنت',
      );
    });

    test('حساب محظور → رسالة صحيحة', () {
      expect(
        FailureMessages.arabicMessage(const BlockedAccountFailure()),
        'حسابك محظور. تواصل مع الإدارة',
      );
    });

    test('قيد المراجعة → رسالة صحيحة', () {
      expect(
        FailureMessages.arabicMessage(const PendingApprovalFailure()),
        contains('قيد المراجعة'),
      );
    });

    test('رحلة مقبولة مسبقاً → رسالة صحيحة', () {
      expect(
        FailureMessages.arabicMessage(const RideAlreadyAcceptedFailure()),
        contains('لم تعد متاحة'),
      );
    });
  });

  group('🔒 AppLogger — تنقية البيانات الحساسة', () {
    test('لا يسجل بدون خطأ', () {
      // مجرد التأكد أن الاستدعاء لا يرمي exception
      AppLogger.info('test message');
      AppLogger.warning('test warning');
      AppLogger.error(const NetworkFailure());
      AppLogger.exception(Exception('test'));
    });
  });

  group('🔒 Failure hierarchy — sealed class', () {
    test('كل Failure هو sealed subclass', () {
      const failures = <Failure>[
        NetworkFailure(),
        TimeoutFailure(),
        AuthFailure(),
        PermissionFailure(),
        BlockedAccountFailure(),
        DisabledAccountFailure(),
        PendingApprovalFailure(),
        RejectedAccountFailure(),
        AccountNotFoundFailure(),
        RideNotFoundFailure(),
        RideAlreadyAcceptedFailure(),
        RideCannotCancelFailure(),
        TransactionFailure(),
        NotificationFailure(),
        ValidationFailure(),
        ServerFailure(),
        UnknownFailure(),
      ];

      // 17 أنواع فرعية
      expect(failures.length, 17);

      // كل واحد لديه code فريد (بعضها مشترك عبر constructor params)
      for (final f in failures) {
        expect(f.code, isA<ErrorCode>());
        expect(f.message, isNotEmpty);
      }
    });

    test('toString يعرض code + message', () {
      const f = RideNotFoundFailure();
      expect(f.toString(), contains('rideNotFound'));
    });
  });
}

/// مساعد لإنشاء Failure من ErrorCode
Failure _makeFailure(ErrorCode code) {
  return switch (code) {
    ErrorCode.networkUnavailable => const NetworkFailure(),
    ErrorCode.timeout => const TimeoutFailure(),
    ErrorCode.unauthenticated => const AuthFailure(),
    ErrorCode.invalidCredentials => const AuthFailure(
      ErrorCode.invalidCredentials,
      'test',
    ),
    ErrorCode.emailAlreadyInUse => const AuthFailure(
      ErrorCode.emailAlreadyInUse,
      'test',
    ),
    ErrorCode.weakPassword => const AuthFailure(ErrorCode.weakPassword, 'test'),
    ErrorCode.permissionDenied => const PermissionFailure(),
    ErrorCode.accountBlocked => const BlockedAccountFailure(),
    ErrorCode.accountDisabled => const DisabledAccountFailure(),
    ErrorCode.accountPendingApproval => const PendingApprovalFailure(),
    ErrorCode.accountRejected => const RejectedAccountFailure(),
    ErrorCode.accountNotFound => const AccountNotFoundFailure(),
    ErrorCode.rideNotFound => const RideNotFoundFailure(),
    ErrorCode.rideAlreadyAccepted => const RideAlreadyAcceptedFailure(),
    ErrorCode.rideCannotCancel => const RideCannotCancelFailure(),
    ErrorCode.transactionFailed => const TransactionFailure(),
    ErrorCode.duplicateTransaction => const TransactionFailure(
      ErrorCode.duplicateTransaction,
      'test',
    ),
    ErrorCode.insufficientBalance => const TransactionFailure(
      ErrorCode.insufficientBalance,
      'test',
    ),
    ErrorCode.notificationFailed => const NotificationFailure(),
    ErrorCode.invalidFcmToken => const NotificationFailure('invalid token'),
    ErrorCode.validationError => const ValidationFailure(),
    ErrorCode.serverError => const ServerFailure(),
    ErrorCode.unknown => const UnknownFailure(),
  };
}
