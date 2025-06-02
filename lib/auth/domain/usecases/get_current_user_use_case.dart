import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';

/// Use case to get the current authenticated user
class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  /// Returns the current user if authenticated, null otherwise
  UserModel? call() {
    return _authRepository.getCurrentUser();
  }
}
