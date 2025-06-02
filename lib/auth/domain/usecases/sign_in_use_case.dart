import '../../../core/network/network_client.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';

/// Sign-in use case that handles user authentication
class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  /// Execute sign-in operation with email and password
  Future<ApiResponse<AuthResponse>> call(String email, String password) {
    return _authRepository.signIn(email, password);
  }
}
