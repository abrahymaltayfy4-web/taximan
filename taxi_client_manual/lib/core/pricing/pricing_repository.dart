import '../domain/pricing_config.dart';
import '../error/result.dart';

/// مصدر إعدادات التسعير (مشترك بين طلب الرحلة عند العميل وقبول/إكمال الرحلة عند الكابتن).
/// يعيد الإعدادات الافتراضية إن لم يوجد المستند، ويعيد Failure عند فشل القراءة.
abstract interface class PricingRepository {
  Future<Result<PricingConfig>> getPricingConfig();
}
