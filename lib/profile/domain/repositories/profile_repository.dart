import '../entities/profile.dart';
import '../../data/models/profile_models.dart';
import '../../../core/utils/api_response.dart';

abstract class ProfileRepository {
  Future<ApiResponse<Profile>> getCurrentProfile();
  Future<ApiResponse<Profile>> getProfileById(String userId);
  Future<ApiResponse<Profile>> createProfile(CreateProfileRequest request);
  Future<ApiResponse<Profile>> updateProfile(String profileId, UpdateProfileRequest request);
  Future<ApiResponse<void>> deleteProfile(String profileId);
  Future<ApiResponse<Profile>> uploadProfilePicture(String profileId, String imagePath);
  Future<ApiResponse<List<Profile>>> searchProfiles({
    String? search,
    String? location,
    List<String>? interests,
    int page = 1,
    int limit = 10,
  });
  
  // Cache management
  Profile? getCachedProfile();
  void updateCache(Profile profile);
  void clearCache();
}
