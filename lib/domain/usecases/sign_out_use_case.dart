import '../../data/repositories/auth_repository.dart';

/// Use case to handle user sign-out
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  /// Signs out the current user
  Future<void> call() {
    return _authRepository.signOut();
  }
}
