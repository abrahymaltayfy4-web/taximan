import 'dart:developer' as dev;
import 'result.dart';

/// Logger آمن — لا يطبع tokens، passwords، بيانات شخصية
class AppLogger {
  const AppLogger._();

  /// أنماط البيانات الحساسة
  static final _sensitivePatterns = [
    RegExp(r'password["\s:=]+\S+', caseSensitive: false),
    RegExp(r'token["\s:=]+\S+', caseSensitive: false),
    RegExp(r'fcmToken["\s:=]+\S+', caseSensitive: false),
    RegExp(r'idToken["\s:=]+\S+', caseSensitive: false),
    RegExp(r'apiKey["\s:=]+\S+', caseSensitive: false),
    RegExp(r'secret["\s:=]+\S+', caseSensitive: false),
    RegExp(r'\b05\d{8}\b'), // أرقام هواتف سعودية
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // إيميل
  ];

  /// تنقية النص من البيانات الحساسة
  static String _sanitize(String text) {
    var result = text;
    for (final pattern in _sensitivePatterns) {
      result = result.replaceAll(pattern, '***REDACTED***');
    }
    return result;
  }

  /// تسجيل معلومات
  static void info(String message, {String? tag}) {
    dev.log(_sanitize(message), name: tag ?? 'APP');
  }

  /// تسجيل تحذير
  static void warning(String message, {String? tag}) {
    dev.log('⚠️ ${_sanitize(message)}', name: tag ?? 'WARN');
  }

  /// تسجيل خطأ مع Failure
  static void error(Failure failure, {String? tag, StackTrace? stack}) {
    final msg = '❌ [${failure.code.name}] ${_sanitize(failure.message)}';
    dev.log(msg, name: tag ?? 'ERROR', stackTrace: stack);
  }

  /// تسجيل exception خام (للـ catch blocks)
  static void exception(Object error, {StackTrace? stack, String? tag}) {
    final msg = _sanitize(error.toString());
    dev.log('💥 $msg', name: tag ?? 'EXCEPTION', stackTrace: stack);
  }
}
