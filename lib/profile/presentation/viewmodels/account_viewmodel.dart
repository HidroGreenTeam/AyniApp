import '../../../auth/domain/usecases/sign_out_use_case.dart';
import '../../../auth/domain/usecases/get_current_user_use_case.dart';
import '../../../auth/data/models/auth_models.dart';

/// ViewModel for the account page following MVVM pattern
/// Acts as an intermediary between View and Model (Use Cases)
class AccountViewModel {
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AccountViewModel({
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _signOutUseCase = signOutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase;

  /// Signs out the current user by clearing stored credentials
  Future<void> signOut() async {
    await _signOutUseCase.call();
  }

  /// Gets the current authenticated user, if available
  /// Returns a UserModel if a user is authenticated, null otherwise
  UserModel? getCurrentUser() {
    return _getCurrentUserUseCase.call();
  }
}
