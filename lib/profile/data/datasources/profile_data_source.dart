import '../../../core/constants/api_constants.dart';
import '../../../core/network/network_client.dart' as network;
import '../../../core/utils/api_response.dart';
import '../models/profile_models.dart';

class ProfileDataSource {
  final network.NetworkClient _networkClient;

  ProfileDataSource(this._networkClient);

  /// Get profile by user ID
  Future<ApiResponse<ProfileModel>> getProfileById(String userId) async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: '${ApiConstants.profiles}/$userId',
      method: network.RequestMethod.get,
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Get current user's profile
  Future<ApiResponse<ProfileModel>> getCurrentProfile() async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: '${ApiConstants.profiles}/me',
      method: network.RequestMethod.get,
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Create a new profile
  Future<ApiResponse<ProfileModel>> createProfile(CreateProfileRequest request) async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: ApiConstants.profiles,
      method: network.RequestMethod.post,
      data: request.toJson(),
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Update existing profile
  Future<ApiResponse<ProfileModel>> updateProfile(String profileId, UpdateProfileRequest request) async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: '${ApiConstants.profiles}/$profileId',
      method: network.RequestMethod.put,
      data: request.toJson(),
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Delete profile
  Future<ApiResponse<void>> deleteProfile(String profileId) async {
    final response = await _networkClient.request<void>(
      endpoint: '${ApiConstants.profiles}/$profileId',
      method: network.RequestMethod.delete,
    );
    
    if (response.success) {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }
  /// Upload profile picture
  Future<ApiResponse<ProfileModel>> uploadProfilePicture(String profileId, String imagePath) async {
    final response = await _networkClient.request<ProfileModel>(
      endpoint: '${ApiConstants.profiles}/$profileId/picture',
      method: network.RequestMethod.post,
      data: {'profilePicture': imagePath},
      fromJson: (json) => ProfileModel.fromJson(json),
    );
    
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }
  /// Search profiles by criteria
  Future<ApiResponse<List<ProfileModel>>> searchProfiles({
    String? search,
    String? location,
    List<String>? interests,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{};
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }
    if (interests != null && interests.isNotEmpty) {
      queryParams['interests'] = interests.join(',');
    }
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();

    // Build query string
    String endpoint = '${ApiConstants.profiles}/search';
    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      endpoint = '$endpoint?$queryString';
    }

    final response = await _networkClient.request<List<ProfileModel>>(
      endpoint: endpoint,
      method: network.RequestMethod.get,
      fromJson: (json) {
        if (json['data'] is List) {
          return (json['data'] as List)
              .map((item) => ProfileModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <ProfileModel>[];
      },
    );
    
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.error ?? 'Unknown error');
    }
  }

  /// Get cached profiles (for offline usage)
  List<ProfileModel> getCachedProfiles() {
    // Implementation would depend on local storage solution
    // For now, return empty list
    return [];
  }

  /// Cache profiles locally
  void cacheProfiles(List<ProfileModel> profiles) {
    // Implementation would depend on local storage solution
    // For now, do nothing
  }

  /// Clear cached profiles
  void clearCache() {
    // Implementation would depend on local storage solution
    // For now, do nothing
  }

  /// Get cached profile by ID
  ProfileModel? getCachedProfileById(String profileId) {
    // Implementation would depend on local storage solution
    // For now, return null
    return null;
  }

  /// Cache single profile
  void cacheProfile(ProfileModel profile) {
    // Implementation would depend on local storage solution
    // For now, do nothing
  }
}
