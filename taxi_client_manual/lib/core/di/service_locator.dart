import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Core Infrastructure
import '../infrastructure/firebase_auth_service.dart';
import '../infrastructure/firestore_service.dart';
import '../infrastructure/directions_service.dart';

// Home feature (Clean Architecture)
import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/cubit/location_cubit.dart';

// Splash feature (Clean Architecture)
import '../../features/splash/domain/usecases/check_client_session_use_case.dart';
import '../../features/splash/cubit/client_splash_cubit.dart';

// Auth feature (Clean Architecture)
import '../../features/auth/repositories/client_auth_repository.dart';
import '../../features/auth/domain/repositories/client_auth_repository_contract.dart';
import '../../features/auth/cubit/client_auth_cubit.dart';

// Rides feature (Clean Architecture)
import '../../features/rides/data/ride_remote_data_source.dart';
import '../../features/rides/data/customer_ride_repository_impl.dart';
import '../../features/rides/domain/customer_ride_repository.dart';
import '../../features/rides/domain/request_ride_use_case.dart';
import '../../features/rides/domain/watch_active_ride_use_case.dart';
import '../../features/rides/domain/cancel_ride_use_case.dart';
import '../../features/rides/domain/load_ride_history_use_case.dart';
import '../../features/rides/presentation/ride_cubit.dart';

// Session feature (Clean Architecture)
import '../../features/session/data/firebase_session_data_source.dart';
import '../../features/session/data/session_repository_impl.dart';
import '../../features/session/domain/session_repository.dart';
import '../../features/session/presentation/session_cubit.dart';

// Profile feature (Clean Architecture)
import '../../features/profile/services/customer_profile_service.dart';
import '../../features/profile/repositories/customer_profile_repository.dart';
import '../../features/profile/domain/repositories/customer_profile_repository_contract.dart';
import '../../features/profile/domain/usecases/get_customer_profile_use_case.dart';
import '../../features/profile/domain/usecases/update_customer_profile_use_case.dart';
import '../../features/profile/cubit/customer_profile_cubit.dart';

// Ride History feature (Clean Architecture)
import '../../features/ride_history/services/client_ride_history_service.dart';
import '../../features/ride_history/repositories/client_ride_history_repository.dart';
import '../../features/ride_history/domain/repositories/client_ride_history_repository_contract.dart';
import '../../features/ride_history/domain/usecases/load_client_ride_history_use_case.dart';
import '../../features/ride_history/cubit/ride_history_cubit.dart';

// Place Search feature (Clean Architecture)
import '../../features/place_search/data/datasources/places_remote_data_source.dart';
import '../../features/place_search/data/repositories/place_search_repository_impl.dart';
import '../../features/place_search/domain/repositories/place_search_repository.dart';
import '../../features/place_search/domain/usecases/search_places_use_case.dart';
import '../../features/place_search/domain/usecases/get_place_details_use_case.dart';
import '../../features/place_search/presentation/cubit/place_search_cubit.dart';
import '../config/app_config.dart';

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
  // Core Services
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<FirestoreService>(
    () => FirestoreService(sl<FirebaseFirestore>()),
  );

  // ═══════════════════════════════════════════
  // Auth Feature (Clean Architecture)
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<ClientAuthRepositoryContract>(
    () => ClientAuthRepository(sl<FirebaseAuth>(), sl<FirebaseFirestore>()),
  );
  sl.registerFactory<ClientAuthCubit>(
    () => ClientAuthCubit(sl<ClientAuthRepositoryContract>()),
  );

  // ═══════════════════════════════════════════
  // Rides Feature (Clean Architecture)
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<RideRemoteDataSource>(
    () => RideRemoteDataSource(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<CustomerRideRepository>(
    () => CustomerRideRepositoryImpl(sl<RideRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(
    () => RequestRideUseCase(sl<CustomerRideRepository>()),
  );
  sl.registerLazySingleton(
    () => WatchActiveRideUseCase(sl<CustomerRideRepository>()),
  );
  sl.registerLazySingleton(
    () => CancelRideUseCase(sl<CustomerRideRepository>()),
  );
  sl.registerLazySingleton(
    () => LoadRideHistoryUseCase(sl<CustomerRideRepository>()),
  );

  // Cubit
  sl.registerFactory<RideCubit>(
    () => RideCubit(
      requestRide: sl<RequestRideUseCase>(),
      watchActiveRide: sl<WatchActiveRideUseCase>(),
      cancelRide: sl<CancelRideUseCase>(),
      directionsService: sl<DirectionsService>(),
    ),
  );

  // ═══════════════════════════════════════════
  // Session Feature (Clean Architecture)
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<FirebaseSessionDataSource>(
    () =>
        FirebaseSessionDataSource(sl<FirebaseAuth>(), sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl<FirebaseSessionDataSource>()),
  );
  sl.registerFactory(() => SessionCubit(sl<SessionRepository>()));

  // ═══════════════════════════════════════════
  // Profile Feature (Clean Architecture)
  // Service → Repo(implements Contract) → UseCases → Cubit
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<CustomerProfileService>(
    () => CustomerProfileService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<CustomerProfileRepositoryContract>(
    () => CustomerProfileRepository(
      sl<CustomerProfileService>(),
      sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton(
    () => GetCustomerProfileUseCase(sl<CustomerProfileRepositoryContract>()),
  );
  sl.registerLazySingleton(
    () => UpdateCustomerProfileUseCase(sl<CustomerProfileRepositoryContract>()),
  );
  sl.registerFactory<CustomerProfileCubit>(
    () => CustomerProfileCubit(
      getProfile: sl<GetCustomerProfileUseCase>(),
      updateProfile: sl<UpdateCustomerProfileUseCase>(),
      auth: sl<FirebaseAuth>(),
    ),
  );

  // ═══════════════════════════════════════════
  // Ride History Feature (Clean Architecture)
  // Service → Repo(implements Contract) → UseCase → Cubit
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<ClientRideHistoryService>(
    () => ClientRideHistoryService(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<ClientRideHistoryRepositoryContract>(
    () => ClientRideHistoryRepository(
      sl<ClientRideHistoryService>(),
      sl<FirebaseAuth>(),
    ),
  );
  sl.registerLazySingleton(
    () => LoadClientRideHistoryUseCase(sl<ClientRideHistoryRepositoryContract>()),
  );
  sl.registerFactory<ClientRideHistoryCubit>(
    () => ClientRideHistoryCubit(sl<LoadClientRideHistoryUseCase>()),
  );

  // ═══════════════════════════════════════════
  // Home Feature (Clean Architecture)
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<DirectionsService>(() => DirectionsService());
  sl.registerFactory<LocationCubit>(() => LocationCubit());
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(sl<FirebaseFirestore>(), sl<DirectionsService>()),
  );

  // ═══════════════════════════════════════════
  // Place Search Feature (Clean Architecture)
  // DataSource → Repo(implements Contract) → UseCases → Cubit
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<PlacesRemoteDataSource>(
    () => PlacesRemoteDataSource(apiKey: AppConfig.mapsApiKey),
  );
  sl.registerLazySingleton<PlaceSearchRepository>(
    () => PlaceSearchRepositoryImpl(sl<PlacesRemoteDataSource>()),
  );
  sl.registerLazySingleton(
    () => SearchPlacesUseCase(sl<PlaceSearchRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPlaceDetailsUseCase(sl<PlaceSearchRepository>()),
  );
  sl.registerFactory<PlaceSearchCubit>(
    () => PlaceSearchCubit(
      searchPlaces: sl<SearchPlacesUseCase>(),
      getPlaceDetails: sl<GetPlaceDetailsUseCase>(),
    ),
  );

  // ═══════════════════════════════════════════
  // Splash Feature (Clean Architecture)
  // UseCase → Cubit
  // ═══════════════════════════════════════════
  sl.registerLazySingleton(
    () => CheckClientSessionUseCase(sl<SessionRepository>()),
  );
  sl.registerFactory<ClientSplashCubit>(
    () => ClientSplashCubit(sl<CheckClientSessionUseCase>()),
  );
}
