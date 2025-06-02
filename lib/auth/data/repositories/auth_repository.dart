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
    final request = AuthRequest(email: email, password: password);
    final response = await _authDataSource.signIn(request);

    if (response.success && response.data != null) {
      // Save token and user data
      await _storageService.saveToken(response.data!.token);
      await _storageService.saveUserData(jsonEncode(response.data!.user.toJson()));
    }

    return response;
  }

  Future<void> signOut() async {
    await _storageService.clearAll();
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
