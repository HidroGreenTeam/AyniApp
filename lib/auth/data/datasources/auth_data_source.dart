import '../../../core/constants/api_constants.dart';
import '../../../core/network/network_client.dart';
import '../models/auth_models.dart';

class AuthDataSource {
  final NetworkClient _networkClient;

  AuthDataSource(this._networkClient);

  Future<ApiResponse<AuthResponse>> signIn(AuthRequest request) async {
    return await _networkClient.request<AuthResponse>(
      endpoint: ApiConstants.signIn,
      method: RequestMethod.post,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  Future<ApiResponse<AuthResponse>> signUp(SignUpRequest request) async {
    return await _networkClient.request<AuthResponse>(
      endpoint: ApiConstants.signUp,
      method: RequestMethod.post,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }
}
