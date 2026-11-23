import 'package:equatable/equatable.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/entities/place_details.dart';

/// حالات Cubit البحث عن الأماكن
abstract class PlaceSearchState extends Equatable {
  const PlaceSearchState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية — حقل البحث فارغ
class PlaceSearchInitial extends PlaceSearchState {
  const PlaceSearchInitial();
}

/// جاري البحث عن اقتراحات
class PlaceSearchLoading extends PlaceSearchState {
  const PlaceSearchLoading();
}

/// تم العثور على اقتراحات
class PlaceSearchLoaded extends PlaceSearchState {
  final List<PlaceSuggestion> suggestions;

  const PlaceSearchLoaded(this.suggestions);

  @override
  List<Object?> get props => [suggestions];
}

/// لا توجد نتائج
class PlaceSearchEmpty extends PlaceSearchState {
  final String query;

  const PlaceSearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

/// خطأ في البحث
class PlaceSearchError extends PlaceSearchState {
  final String message;

  const PlaceSearchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// جاري جلب تفاصيل المكان المحدد
class PlaceDetailsLoading extends PlaceSearchState {
  const PlaceDetailsLoading();
}

/// تم جلب تفاصيل المكان بنجاح — يحمل الإحداثيات والاسم
class PlaceDetailsLoaded extends PlaceSearchState {
  final PlaceDetails details;

  const PlaceDetailsLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

/// خطأ في جلب التفاصيل
class PlaceDetailsError extends PlaceSearchState {
  final String message;

  const PlaceDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
