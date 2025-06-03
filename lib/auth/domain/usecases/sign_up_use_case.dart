import '../../../core/network/network_client.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';

/// Sign-up use case that handles user registration
class SignUpUseCase {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  /// Execute sign-up operation with fullName, email, password
  Future<ApiResponse<AuthResponse>> call(String fullName, String email, String password) {
    return _authRepository.signUp(fullName, email, password);
  }
}
