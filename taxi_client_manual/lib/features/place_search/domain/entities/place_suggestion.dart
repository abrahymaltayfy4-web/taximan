import 'package:equatable/equatable.dart';

/// كيان اقتراح مكان — يمثّل نتيجة بحث واحدة من Google Places API
/// يُستخدم فقط في طبقة الـ Domain والـ Presentation
class PlaceSuggestion extends Equatable {
  /// معرّف فريد من Google يُستخدم لجلب التفاصيل لاحقاً
  final String placeId;

  /// الاسم الرئيسي للمكان (مثلاً: "مستشفى الثورة")
  final String mainText;

  /// الوصف الثانوي (مثلاً: "صنعاء, اليمن")
  final String secondaryText;

  /// الوصف الكامل كما يظهر من API
  final String fullDescription;

  const PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullDescription,
  });

  @override
  List<Object?> get props => [placeId, mainText, secondaryText, fullDescription];
}
