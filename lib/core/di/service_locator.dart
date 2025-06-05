import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_client.dart';
import '../services/storage_service.dart';
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
import '../../auth/presentation/viewmodels/walkthrough_viewmodel.dart';
import '../../profile/presentation/blocs/account_bloc.dart';
import '../../profile/presentation/viewmodels/account_viewmodel.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);
  serviceLocator.registerSingleton<http.Client>(http.Client());

  // Core
  serviceLocator.registerSingleton<NetworkClient>(
    NetworkClient(client: serviceLocator<http.Client>()),
  );
  serviceLocator.registerSingleton<StorageService>(
    StorageService(serviceLocator<SharedPreferences>()),
  );

  // Data sources
  serviceLocator.registerSingleton<AuthDataSource>(
    AuthDataSource(serviceLocator<NetworkClient>()),
  );

  // Repositories
  serviceLocator.registerSingleton<AuthRepository>(
    AuthRepository(
      serviceLocator<AuthDataSource>(),
      serviceLocator<StorageService>(),
    ),  );
  
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
}
