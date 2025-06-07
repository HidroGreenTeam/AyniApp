import 'dart:convert';
import '../../../core/network/network_client.dart';
import '../../../core/services/storage_service.dart';
import '../datasources/auth_data_source.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final AuthDataSource _authDataSource;
  final StorageService _storageService;

  AuthRepository(this._authDataSource, this._storageService);

  Future<ApiResponse<AuthResponse>> signIn(String email, String password) async {
    final response = await _authDataSource.signIn(AuthRequest(email: email, password: password));
    if (response.success && response.data != null) {
      await _storageService.saveToken(response.data!.token);
      await _storageService.saveUserData(jsonEncode(response.data!.user.toJson()));
      await _storageService.setString('user_id', response.data!.user.id.toString());
    }
    return response;
  }

  Future<ApiResponse<AuthResponse>> signUp(String fullName, String email, String password) async {
    final request = SignUpRequest(
      fullName: fullName, 
      email: email, 
      password: password,
      roles: ["ROLE_USER"] // Default role for new users
    );
    final response = await _authDataSource.signUp(request);

    if (response.success && response.data != null) {
      // Save token and user data
      await _storageService.saveToken(response.data!.token);
      await _storageService.saveUserData(jsonEncode(response.data!.user.toJson()));
      // Save user id as string (for profile CRUD)
      await _storageService.setString('user_id', response.data!.user.id.toString());
    }

    return response;
  }
  Future<void> signOut() async {
    await _storageService.clearAuthData();
  }

  bool isAuthenticated() {
    return _storageService.getToken() != null;
  }

  UserModel? getCurrentUser() {
    final userData = _storageService.getUserData();
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }
}
