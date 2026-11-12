import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:taxi_captain_manual/features/profile/cubit/profile_cubit.dart';
import 'package:taxi_captain_manual/features/profile/domain/entities/driver_profile_entity.dart';
import 'package:taxi_captain_manual/features/profile/domain/repositories/profile_repository_contract.dart';
import 'package:taxi_captain_manual/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:taxi_captain_manual/features/profile/domain/usecases/update_profile_use_case.dart';

/// ═══════════════════════════════════════════
/// Fake ProfileRepository — بدون Firebase
/// ═══════════════════════════════════════════
class FakeProfileRepository implements ProfileRepositoryContract {
  DriverProfileEntity? profileToReturn;
  bool shouldThrow = false;
  String throwMessage = 'fake error';
  int updateCallCount = 0;

  @override
  Future<DriverProfileEntity?> getProfile() async {
    if (shouldThrow) throw Exception(throwMessage);
    return profileToReturn;
  }

  @override
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? carModel,
    String? carPlate,
    double? pricePerKm,
  }) async {
    updateCallCount++;
    if (shouldThrow) throw Exception(throwMessage);
  }
}

const _fakeDriver = DriverProfileEntity(
  uid: 'fake-uid',
  name: 'أحمد',
  phone: '0512345678',
  email: 'test@test.com',
  carModel: 'Toyota',
  carPlate: 'ABC 123',
  pricePerKm: 500,
  status: 'online',
);

void main() {
  late FakeProfileRepository repo;

  setUp(() {
    repo = FakeProfileRepository();
  });

  group('🔒 ProfileCubit مع Fake Repository', () {
    blocTest<ProfileCubit, ProfileState>(
      'loadProfile ناجح → ProfileLoading → ProfileLoaded',
      build: () {
        repo.profileToReturn = _fakeDriver;
        return ProfileCubit(
          getProfile: GetProfileUseCase(repo),
          updateProfile: UpdateProfileUseCase(repo),
        );
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>().having((s) => s.driver.name, 'name', 'أحمد'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'loadProfile بدون بيانات → ProfileError',
      build: () {
        repo.profileToReturn = null;
        return ProfileCubit(
          getProfile: GetProfileUseCase(repo),
          updateProfile: UpdateProfileUseCase(repo),
        );
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'loadProfile فشل شبكة → ProfileError',
      build: () {
        repo.shouldThrow = true;
        repo.throwMessage = 'Network error';
        return ProfileCubit(
          getProfile: GetProfileUseCase(repo),
          updateProfile: UpdateProfileUseCase(repo),
        );
      },
      act: (cubit) => cubit.loadProfile(),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>().having(
          (s) => s.message,
          'msg',
          contains('Network'),
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'updateProfile ناجح → ProfileUpdating → ProfileUpdated → يعيد التحميل',
      build: () {
        repo.profileToReturn = _fakeDriver;
        return ProfileCubit(
          getProfile: GetProfileUseCase(repo),
          updateProfile: UpdateProfileUseCase(repo),
        );
      },
      act: (cubit) => cubit.updateProfile(name: 'محمد'),
      expect: () => [
        isA<ProfileUpdating>(),
        isA<ProfileUpdated>(),
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
      ],
      verify: (_) {
        expect(repo.updateCallCount, 1);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'updateProfile فاشل → ProfileError',
      build: () {
        repo.shouldThrow = true;
        return ProfileCubit(
          getProfile: GetProfileUseCase(repo),
          updateProfile: UpdateProfileUseCase(repo),
        );
      },
      act: (cubit) => cubit.updateProfile(name: 'test'),
      expect: () => [isA<ProfileUpdating>(), isA<ProfileError>()],
    );
  });
}
