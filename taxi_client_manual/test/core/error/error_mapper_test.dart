import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxi_client_manual/core/error/error_mapper.dart';
import 'package:taxi_client_manual/core/error/result.dart';

/// ═══════════════════════════════════════════
/// ErrorMapper — Firebase/Network → Domain Failure
/// ═══════════════════════════════════════════
void main() {
  group('🔒 ErrorMapper.mapException', () {
    test('SocketException → NetworkFailure', () {
      final f = ErrorMapper.mapException(const SocketException('no route'));
      expect(f, isA<NetworkFailure>());
      expect(f.code, ErrorCode.networkUnavailable);
    });

    test('HttpException → NetworkFailure', () {
      final f = ErrorMapper.mapException(const HttpException('503'));
      expect(f, isA<NetworkFailure>());
    });

    test('TimeoutException → TimeoutFailure', () {
      final f = ErrorMapper.mapException(TimeoutException('timed out'));
      expect(f, isA<TimeoutFailure>());
      expect(f.code, ErrorCode.timeout);
    });

    test('Exception("محظور") → BlockedAccountFailure', () {
      final f = ErrorMapper.mapException(Exception('حسابك محظور'));
      expect(f, isA<BlockedAccountFailure>());
      expect(f.code, ErrorCode.accountBlocked);
    });

    test('Exception("قيد المراجعة") → PendingApprovalFailure', () {
      final f = ErrorMapper.mapException(Exception('حسابك قيد المراجعة'));
      expect(f, isA<PendingApprovalFailure>());
      expect(f.code, ErrorCode.accountPendingApproval);
    });

    test('Exception("غير موجود") → RideNotFoundFailure', () {
      final f = ErrorMapper.mapException(Exception('الرحلة غير موجود'));
      expect(f, isA<RideNotFoundFailure>());
    });

    test('Exception("مقبولة مسبقاً") → RideAlreadyAcceptedFailure', () {
      final f = ErrorMapper.mapException(Exception('الرحلة مقبولة مسبقاً'));
      expect(f, isA<RideAlreadyAcceptedFailure>());
    });

    test('Exception عشوائي → UnknownFailure', () {
      final f = ErrorMapper.mapException(Exception('something random'));
      expect(f, isA<UnknownFailure>());
      expect(f.code, ErrorCode.unknown);
    });

    test('Object عشوائي → UnknownFailure', () {
      final f = ErrorMapper.mapException(42);
      expect(f, isA<UnknownFailure>());
    });
  });

  group('🔒 safeCall', () {
    test('نجاح → Result.success', () async {
      final result = await safeCall(() async => 42);
      expect(result.isSuccess, isTrue);
      expect(result.data, 42);
    });

    test('SocketException → Result.failure(NetworkFailure)', () async {
      final result = await safeCall<int>(() async {
        throw const SocketException('fail');
      });
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NetworkFailure>());
    });

    test('TimeoutException → Result.failure(TimeoutFailure)', () async {
      final result = await safeCall<int>(() async {
        throw TimeoutException('timeout');
      });
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<TimeoutFailure>());
    });

    test('لا catch عام يخفي نوع الخطأ', () async {
      final result = await safeCall<int>(() async {
        throw Exception('محظور');
      });
      // يجب أن ينتج BlockedAccountFailure وليس UnknownFailure
      expect(result.failure, isA<BlockedAccountFailure>());
      expect(result.failure, isNot(isA<UnknownFailure>()));
    });
  });
}
