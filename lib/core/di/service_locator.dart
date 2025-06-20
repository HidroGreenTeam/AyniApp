import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_client.dart';
import '../services/storage_service.dart';
import '../services/connectivity_service.dart';
import '../../auth/data/datasources/auth_data_source.dart';
import '../../auth/data/repositories/auth_repository.dart';
import '../../auth/domain/usecases/sign_in_use_case.dart';
import '../../auth/domain/usecases/sign_up_use_case.dart';
import '../../auth/domain/usecases/check_auth_status_use_case.dart';
import '../../auth/domain/usecases/get_current_user_use_case.dart';
import '../../auth/domain/usecases/sign_out_use_case.dart';
import '../../auth/domain/usecases/walkthrough_use_case.dart';
import '../../auth/presentation/blocs/auth_bloc.dart';
import '../../auth/presentation/blocs/walkthrough_bloc.dart';
import '../../auth/presentation/viewmodels/login_viewmodel.dart';
import '../../profile/data/datasources/profile_data_source.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../../profile/data/repositories/profile_repository_impl.dart';
import '../../auth/presentation/viewmodels/walkthrough_viewmodel.dart';
import '../../profile/domain/usecases/profile_usecases.dart';
import '../../profile/presentation/blocs/account_bloc.dart';
import '../../profile/presentation/blocs/profile_bloc.dart';
import '../../profile/presentation/viewmodels/account_viewmodel.dart';
import '../../profile/presentation/viewmodels/profile_viewmodel.dart';
import '../../plant/data/datasources/crop_data_source.dart';
import '../../plant/data/repositories/crop_repository.dart';
import '../../plant/domain/usecases/get_all_crops.dart';
import '../../plant/presentation/bolcs/crop_bloc.dart';
import '../../detection/services/hybrid_detection_service.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);
  serviceLocator.registerSingleton<http.Client>(http.Client());

  // Core - Register StorageService first
  serviceLocator.registerSingleton<StorageService>(
    StorageService(serviceLocator<SharedPreferences>()),
  );
  
  serviceLocator.registerSingleton<NetworkClient>(
    NetworkClient(
      client: serviceLocator<http.Client>(),
      storageService: serviceLocator<StorageService>(),
    ),
  );

  // Services
  serviceLocator.registerSingleton<ConnectivityService>(
    ConnectivityService(),
  );

  serviceLocator.registerSingleton<HybridDetectionService>(
    HybridDetectionService(),
  );

  // Data sources
  serviceLocator.registerSingleton<AuthDataSource>(
    AuthDataSource(serviceLocator<NetworkClient>()),
  );
  serviceLocator.registerSingleton<ProfileDataSource>(
    ProfileDataSource(
      serviceLocator<NetworkClient>(),
      serviceLocator<StorageService>(), // Add the missing argument here
    ),
  );

  serviceLocator.registerSingleton<CropDataSource>(
    CropDataSource(serviceLocator<NetworkClient>()),
  );
  // Repositories
  serviceLocator.registerSingleton<AuthRepository>(
    AuthRepository(
      serviceLocator<AuthDataSource>(),
      serviceLocator<StorageService>(),
    ),  );  serviceLocator.registerSingleton<ProfileRepository>(
    ProfileRepositoryImpl(
      serviceLocator<ProfileDataSource>(),
      serviceLocator<StorageService>(),
    ),
  );

  serviceLocator.registerSingleton<CropRepository>(
    CropRepository(
      networkClient: serviceLocator<NetworkClient>(),
    ),
  );
  
  // Domain - Use Cases
  serviceLocator.registerFactory<SignInUseCase>(
    () => SignInUseCase(serviceLocator<AuthRepository>()),
  );
  
  serviceLocator.registerFactory<SignUpUseCase>(
    () => SignUpUseCase(serviceLocator<AuthRepository>()),
  );
  
  serviceLocator.registerFactory<CheckAuthStatusUseCase>(
    () => CheckAuthStatusUseCase(serviceLocator<AuthRepository>()),
  );
    serviceLocator.registerFactory<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(serviceLocator<AuthRepository>()),
  );
    serviceLocator.registerFactory<SignOutUseCase>(
    () => SignOutUseCase(serviceLocator<AuthRepository>()),
  );
    serviceLocator.registerFactory<WalkthroughUseCase>(
    () => WalkthroughUseCase(serviceLocator<StorageService>()),
  );

  // Profile Use Cases
  serviceLocator.registerFactory<GetProfileUseCase>(
    () => GetProfileUseCase(serviceLocator<ProfileRepository>()),
  );

  serviceLocator.registerFactory<GetCurrentProfileUseCase>(
    () => GetCurrentProfileUseCase(serviceLocator<ProfileRepository>()),
  );

  serviceLocator.registerFactory<CreateProfileUseCase>(
    () => CreateProfileUseCase(serviceLocator<ProfileRepository>()),
  );

  serviceLocator.registerFactory<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(serviceLocator<ProfileRepository>()),
  );

  serviceLocator.registerFactory<DeleteProfileUseCase>(
    () => DeleteProfileUseCase(serviceLocator<ProfileRepository>()),
  );

  serviceLocator.registerFactory<UploadProfilePictureUseCase>(
    () => UploadProfilePictureUseCase(serviceLocator<ProfileRepository>()),
  );

  serviceLocator.registerFactory<SearchProfilesUseCase>(
    () => SearchProfilesUseCase(serviceLocator<ProfileRepository>()),
  );
  serviceLocator.registerFactory<GetCachedProfileUseCase>(
    () => GetCachedProfileUseCase(serviceLocator<ProfileRepository>()),
  );
  serviceLocator.registerFactory<ClearProfileCacheUseCase>(
    () => ClearProfileCacheUseCase(serviceLocator<ProfileRepository>()),
  );

  // Plant Use Cases
  serviceLocator.registerFactory<GetAllCrops>(
    () => GetAllCrops(serviceLocator<CropDataSource>()),
  );
    // ViewModels
  serviceLocator.registerFactory<LoginViewModel>(() =>
    LoginViewModel(
      signInUseCase: serviceLocator<SignInUseCase>(),
      signUpUseCase: serviceLocator<SignUpUseCase>(),
      checkAuthStatusUseCase: serviceLocator<CheckAuthStatusUseCase>(),
      getCurrentUserUseCase: serviceLocator<GetCurrentUserUseCase>(),
      signOutUseCase: serviceLocator<SignOutUseCase>(),
    ),
  );
    serviceLocator.registerFactory<WalkthroughViewModel>(() =>
    WalkthroughViewModel(
      walkthroughUseCase: serviceLocator<WalkthroughUseCase>(),
    ),
  );
    serviceLocator.registerFactory<AccountViewModel>(() =>
    AccountViewModel(
      signOutUseCase: serviceLocator<SignOutUseCase>(),
      getCurrentUserUseCase: serviceLocator<GetCurrentUserUseCase>(),
    ),
  );  serviceLocator.registerFactory<ProfileViewModel>(() =>
    ProfileViewModel(
      getProfileUseCase: serviceLocator<GetProfileUseCase>(),
      getCurrentProfileUseCase: serviceLocator<GetCurrentProfileUseCase>(),
      createProfileUseCase: serviceLocator<CreateProfileUseCase>(),
      updateProfileUseCase: serviceLocator<UpdateProfileUseCase>(),
      deleteProfileUseCase: serviceLocator<DeleteProfileUseCase>(),
      uploadProfilePictureUseCase: serviceLocator<UploadProfilePictureUseCase>(),
      searchProfilesUseCase: serviceLocator<SearchProfilesUseCase>(),
      getCachedProfileUseCase: serviceLocator<GetCachedProfileUseCase>(),
      clearProfileCacheUseCase: serviceLocator<ClearProfileCacheUseCase>(),
      getCurrentUserUseCase: serviceLocator<GetCurrentUserUseCase>(),
    ),
  );
  
  // Blocs
  serviceLocator.registerFactory<AuthBloc>(() => 
    AuthBloc(loginViewModel: serviceLocator<LoginViewModel>()),
  );
  
  serviceLocator.registerFactory<WalkthroughBloc>(() => 
    WalkthroughBloc(walkthroughViewModel: serviceLocator<WalkthroughViewModel>()),
  );
    serviceLocator.registerFactory<AccountBloc>(() => 
    AccountBloc(accountViewModel: serviceLocator<AccountViewModel>()),
  );
  serviceLocator.registerFactory<ProfileBloc>(() => 
    ProfileBloc(profileViewModel: serviceLocator<ProfileViewModel>()),
  );
  serviceLocator.registerFactory<CropBloc>(() => 
    CropBloc(
      serviceLocator<GetCurrentUserUseCase>(),
      serviceLocator<CropRepository>(),
    ),
  );
}
