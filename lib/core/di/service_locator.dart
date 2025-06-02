import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_client.dart';
import '../services/storage_service.dart';
import '../../data/datasources/auth_data_source.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../presentation/blocs/auth_bloc.dart';
import '../../presentation/viewmodels/login_viewmodel.dart';

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
  
  serviceLocator.registerFactory<CheckAuthStatusUseCase>(
    () => CheckAuthStatusUseCase(serviceLocator<AuthRepository>()),
  );
    serviceLocator.registerFactory<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(serviceLocator<AuthRepository>()),
  );
  
  serviceLocator.registerFactory<SignOutUseCase>(
    () => SignOutUseCase(serviceLocator<AuthRepository>()),
  );
    // ViewModels
  serviceLocator.registerFactory<LoginViewModel>(() =>
    LoginViewModel(
      signInUseCase: serviceLocator<SignInUseCase>(),
      checkAuthStatusUseCase: serviceLocator<CheckAuthStatusUseCase>(),
      getCurrentUserUseCase: serviceLocator<GetCurrentUserUseCase>(),
      signOutUseCase: serviceLocator<SignOutUseCase>(),
    ),
  );
  
  // Blocs
  serviceLocator.registerFactory<AuthBloc>(() => 
    AuthBloc(loginViewModel: serviceLocator<LoginViewModel>()),
  );
}
