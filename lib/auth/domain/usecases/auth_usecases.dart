import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../core/network/network_client.dart';

/// Sign In Use Case - MVVM pattern
/// Handles the business logic for user sign in
class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);
  Future<ApiResponse<AuthResponse>> call(String email, String password) async {
    return await _authRepository.signIn(email, password);
  }
}

/// Check Authentication Status Use Case
/// Determines if a user is currently authenticated
class CheckAuthStatusUseCase {
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase(this._authRepository);
  bool call() {
    return _authRepository.isAuthenticated();
  }
}

/// Get Current User Use Case
/// Retrieves the current authenticated user if available
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);
  UserModel? call() {
    return _authRepository.getCurrentUser();
  }
}

/// Sign Out Use Case
/// Handles user sign out logic
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);
  Future<void> call() async {
    await _authRepository.signOut();
  }
}
