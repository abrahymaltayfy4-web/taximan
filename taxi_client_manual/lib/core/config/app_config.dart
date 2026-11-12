/// إعدادات التطبيق القابلة للحقن وقت البناء:
/// `flutter run --dart-define=MAPS_API_KEY=xxxx`
/// القيمة الافتراضية هي نفس المفتاح المستخدم سابقاً حفاظاً على السلوك الحالي.
abstract final class AppConfig {
  static const String mapsApiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'AIzaSyA1tBE_7QmoNJvjCVpT-fQkJXuhjUtqCTs',
  );
}
