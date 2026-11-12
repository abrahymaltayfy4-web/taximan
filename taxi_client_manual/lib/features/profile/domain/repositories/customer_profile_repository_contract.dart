import '../entities/customer_profile_entity.dart';

/// عقد Repository — Domain Layer
abstract class CustomerProfileRepositoryContract {
  Future<CustomerProfileEntity?> getProfile();
  Future<void> updateProfile({required String name, required String phone});
}
