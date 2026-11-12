import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Core Infrastructure
import '../infrastructure/firebase_auth_service.dart';
import '../infrastructure/firestore_service.dart';
import '../infrastructure/ride_service.dart';
import '../infrastructure/pricing_service.dart';
import '../infrastructure/transaction_service.dart';
import '../infrastructure/directions_service.dart';

// Feature: Auth (Clean Architecture)
import '../../repositories/auth_repository.dart';
import '../../repositories/driver_repository.dart';
import '../../features/driver_auth/domain/repositories/auth_repository_contract.dart';
import '../../features/driver_auth/domain/repositories/driver_repository_contract.dart';
import '../../features/driver_auth/domain/usecases/login_driver_use_case.dart';
import '../../features/driver_auth/domain/usecases/register_driver_use_case.dart';
import '../../features/driver_auth/cubit/driver_auth_cubit.dart';
import '../../features/driver_home/cubit/driver_home_cubit.dart';
import '../../features/driver_home/cubit/location_cubit.dart';
import '../../features/driver_home/cubit/ride_map_cubit.dart';

// Feature: Rides (Clean Architecture)
import '../../features/rides/domain/repositories/ride_repository.dart';
import '../../features/rides/domain/usecases/watch_pending_rides_use_case.dart';
import '../../features/rides/domain/usecases/accept_ride_use_case.dart';
import '../../features/rides/domain/usecases/complete_ride_use_case.dart';
import '../../features/rides/domain/usecases/update_ride_status_use_case.dart';
import '../../features/rides/domain/usecases/watch_active_ride_use_case.dart';
import '../../features/rides/data/repositories/ride_repository_impl.dart';
import '../../features/rides/presentation/cubit/captain_ride_cubit.dart';

// Feature: Profile (Clean Architecture)
import '../../features/profile/services/profile_service.dart';
import '../../features/profile/repositories/profile_repository.dart';
import '../../features/profile/domain/repositories/profile_repository_contract.dart';
import '../../features/profile/domain/usecases/get_profile_use_case.dart';
import '../../features/profile/domain/usecases/update_profile_use_case.dart';
import '../../features/profile/cubit/profile_cubit.dart';

// Feature: Ride History (Clean Architecture)
import '../../features/ride_history/services/ride_history_service.dart';
import '../../features/ride_history/repositories/ride_history_repository.dart';
import '../../features/ride_history/domain/repositories/ride_history_repository_contract.dart';
import '../../features/ride_history/domain/usecases/load_ride_history_use_case.dart';
import '../../features/ride_history/cubit/ride_history_cubit.dart';

// Feature: Account
import '../../features/account/repositories/account_repository.dart';
import '../../features/account/cubit/account_cubit.dart';

// Feature: Splash
import '../../features/splash/domain/usecases/check_driver_session_use_case.dart';
import '../../features/splash/cubit/splash_cubit.dart';

final sl = GetIt.instance;

/// تهيئة جميع الاعتماديات — يُستدعى مرة واحدة في main()
Future<void> initDependencies() async {
  // ═══════════════════════════════════════════
  // External (Firebase instances) — المكان الوحيد لـ .instance
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  // ═══════════════════════════════════════════
  // Core Infrastructure
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<FirestoreService>(
    () => FirestoreService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<RideService>(
    () => RideService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<PricingService>(
    () => PricingService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<TransactionService>(
    () => TransactionService(sl<FirebaseFirestore>()),
  );

  // ═══════════════════════════════════════════
  // Feature: Auth (Clean Architecture)
  // Repos → Contracts → UseCases → Cubits
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<AuthRepositoryContract>(
    () => AuthRepository(sl<FirebaseAuthService>()),
  );
  sl.registerLazySingleton<DriverRepositoryContract>(
    () => DriverRepository(sl<FirestoreService>()),
  );
  sl.registerLazySingleton(
    () => LoginDriverUseCase(sl<AuthRepositoryContract>(), sl<DriverRepositoryContract>()),
  );
  sl.registerLazySingleton(
    () => RegisterDriverUseCase(sl<AuthRepositoryContract>(), sl<DriverRepositoryContract>()),
  );
  sl.registerFactory<DriverAuthCubit>(
    () => DriverAuthCubit(
      loginDriver: sl<LoginDriverUseCase>(),
      registerDriver: sl<RegisterDriverUseCase>(),
    ),
  );
  sl.registerFactory<DriverHomeCubit>(
    () => DriverHomeCubit(
      sl<DriverRepositoryContract>(),
      sl<FirebaseAuth>(),
      sl<FirebaseFirestore>(),
    ),
  );
  sl.registerFactory<LocationCubit>(() => LocationCubit());
  sl.registerLazySingleton<DirectionsService>(() => DirectionsService());
  sl.registerFactory<RideMapCubit>(
    () => RideMapCubit(sl<DirectionsService>()),
  );

  // ═══════════════════════════════════════════
  // Feature: Rides (Clean Architecture)
  // DataSource → Repository → UseCases → Cubit
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<CaptainRideRepository>(
    () => CaptainRideRepositoryImpl(sl<RideService>()),
  );
  sl.registerLazySingleton(() => WatchPendingRidesUseCase(sl<CaptainRideRepository>()));
  sl.registerLazySingleton(() => AcceptRideUseCase(sl<CaptainRideRepository>()));
  sl.registerLazySingleton(() => CompleteRideUseCase(sl<CaptainRideRepository>()));
  sl.registerLazySingleton(() => UpdateRideStatusUseCase(sl<CaptainRideRepository>()));
  sl.registerLazySingleton(() => WatchActiveRideUseCase(sl<CaptainRideRepository>()));
  sl.registerFactory<CaptainRideCubit>(
    () => CaptainRideCubit(
      watchPendingRides: sl<WatchPendingRidesUseCase>(),
      acceptRide: sl<AcceptRideUseCase>(),
      completeRide: sl<CompleteRideUseCase>(),
      updateRideStatus: sl<UpdateRideStatusUseCase>(),
      watchActiveRide: sl<WatchActiveRideUseCase>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  // ═══════════════════════════════════════════
  // Feature: Profile (Clean Architecture)
  // DataSource → Repository → UseCases → Cubit
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<ProfileService>(
    () => ProfileService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ProfileRepositoryContract>(
    () => ProfileRepository(sl<ProfileService>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepositoryContract>()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl<ProfileRepositoryContract>()));
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getProfile: sl<GetProfileUseCase>(),
      updateProfile: sl<UpdateProfileUseCase>(),
    ),
  );

  // ═══════════════════════════════════════════
  // Feature: Ride History (Clean Architecture)
  // DataSource → Repository → UseCase → Cubit
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<RideHistoryService>(
    () => RideHistoryService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<RideHistoryRepositoryContract>(
    () => RideHistoryRepository(sl<RideHistoryService>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton(() => LoadRideHistoryUseCase(sl<RideHistoryRepositoryContract>()));
  sl.registerFactory<RideHistoryCubit>(
    () => RideHistoryCubit(sl<LoadRideHistoryUseCase>()),
  );

  // ═══════════════════════════════════════════
  // Feature: Account
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepository(
      firestore: sl<FirebaseFirestore>(),
      auth: sl<FirebaseAuth>(),
    ),
  );
  sl.registerFactory<AccountCubit>(
    () => AccountCubit(sl<AccountRepository>()),
  );

  // ═══════════════════════════════════════════
  // Feature: Splash
  // UseCase → Cubit
  // ═══════════════════════════════════════════
  sl.registerLazySingleton(
    () => CheckDriverSessionUseCase(sl<FirebaseAuth>(), sl<FirebaseFirestore>()),
  );
  sl.registerFactory<SplashCubit>(
    () => SplashCubit(sl<CheckDriverSessionUseCase>()),
  );
}
