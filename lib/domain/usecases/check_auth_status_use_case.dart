import '../../data/repositories/auth_repository.dart';

/// Use case to check if the user is currently authenticated
class CheckAuthStatusUseCase {
  final AuthRepository _authRepository;

  CheckAuthStatusUseCase(this._authRepository);

  /// Returns whether the user is authenticated or not
  bool call() {
    return _authRepository.isAuthenticated();
  }
}
