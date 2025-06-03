import '../../data/models/auth_models.dart';
import '../../../core/network/network_client.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import '../../domain/usecases/check_auth_status_use_case.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';

/// ViewModel for the login functionality following MVVM pattern
/// Acts as an intermediary between View (BLoC) and Model (Use Cases)
class LoginViewModel {
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignOutUseCase _signOutUseCase;

  LoginViewModel({
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignOutUseCase signOutUseCase,
  }) :    _signInUseCase = signInUseCase,
    _signUpUseCase = signUpUseCase,
    _checkAuthStatusUseCase = checkAuthStatusUseCase,
    _getCurrentUserUseCase = getCurrentUserUseCase,
    _signOutUseCase = signOutUseCase;
    
  /// Attempts to sign in a user with email and password
  /// Returns an ApiResponse containing auth data or error
  Future<ApiResponse<AuthResponse>> signIn(String email, String password) async {
    return await _signInUseCase.call(email, password);
  }
    /// Signs up a new user with fullName, email and password
  /// Returns an ApiResponse containing auth data or error
  Future<ApiResponse<AuthResponse>> signUp(String fullName, String email, String password) async {
    return await _signUpUseCase.call(fullName, email, password);
  }

  /// Checks if the user is currently authenticated
  /// Returns true if there is a valid token stored, false otherwise
  bool isAuthenticated() {
    return _checkAuthStatusUseCase.call();
  }
  /// Gets the current authenticated user, if available
  /// Returns a UserModel if a user is authenticated, null otherwise
  UserModel? getCurrentUser() {
    return _getCurrentUserUseCase.call();
  }

  /// Signs out the current user by clearing stored credentials
  /// This is essential for the MVVM pattern as it encapsulates the
  /// business logic for sign-out functionality
  Future<void> signOut() async {
    await _signOutUseCase.call();
  }
}
