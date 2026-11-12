import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firestore_collections.dart';
import '../domain/pricing_config.dart';
import '../error/error_mapper.dart';
import '../error/result.dart';
import 'pricing_mapper.dart';
import 'pricing_repository.dart';

class FirestorePricingRepository implements PricingRepository {
  final FirebaseFirestore _firestore;

  const FirestorePricingRepository(this._firestore);

  @override
  Future<Result<PricingConfig>> getPricingConfig() {
    return safeCall(() async {
      final doc = await _firestore
          .collection(FirestoreCollections.settings)
          .doc(FirestoreCollections.pricingDoc)
          .get();
      final data = doc.data();
      if (!doc.exists || data == null) return const PricingConfig();
      return PricingMapper.fromMap(data);
    });
  }
}
