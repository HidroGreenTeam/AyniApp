import '../../../core/utils/api_response.dart';
import '../entities/profile.dart';
import '../../data/models/profile_models.dart';
import '../repositories/profile_repository.dart';

/// Get Profile Use Case
/// Retrieves a profile by user ID
class GetProfileUseCase {
  final ProfileRepository _profileRepository;

  GetProfileUseCase(this._profileRepository);

  Future<ApiResponse<Profile>> call(String userId) {
    return _profileRepository.getProfileById(userId);
  }
}

/// Get Current Profile Use Case
/// Retrieves the current user's profile
class GetCurrentProfileUseCase {
  final ProfileRepository _profileRepository;

  GetCurrentProfileUseCase(this._profileRepository);

  Future<ApiResponse<Profile>> call() {
    return _profileRepository.getCurrentProfile();
  }
}

/// Get Cached Profile Use Case
/// Retrieves the current user's profile from cache
class GetCachedProfileUseCase {
  final ProfileRepository _profileRepository;

  GetCachedProfileUseCase(this._profileRepository);

  Profile? call() {
    return _profileRepository.getCachedProfile();
  }
}

/// Clear Profile Cache Use Case
/// Clears the current user's profile cache
class ClearProfileCacheUseCase {
  final ProfileRepository _profileRepository;

  ClearProfileCacheUseCase(this._profileRepository);

  void call() {
    _profileRepository.clearCache();
  }
}

/// Create Profile Use Case
/// Creates a new profile for the current user
class CreateProfileUseCase {
  final ProfileRepository _profileRepository;

  CreateProfileUseCase(this._profileRepository);

  Future<ApiResponse<Profile>> call(CreateProfileRequest request) {
    return _profileRepository.createProfile(request);
  }
}

/// Update Profile Use Case
/// Updates an existing profile
class UpdateProfileUseCase {
  final ProfileRepository _profileRepository;

  UpdateProfileUseCase(this._profileRepository);

  Future<ApiResponse<Profile>> call(String profileId, UpdateProfileRequest request) {
    return _profileRepository.updateProfile(profileId, request);
  }
}

/// Delete Profile Use Case
/// Deletes a profile
class DeleteProfileUseCase {
  final ProfileRepository _profileRepository;

  DeleteProfileUseCase(this._profileRepository);

  Future<ApiResponse<void>> call(String profileId) {
    return _profileRepository.deleteProfile(profileId);
  }
}

/// Upload Profile Picture Use Case
/// Uploads a profile picture for a user
class UploadProfilePictureUseCase {
  final ProfileRepository _profileRepository;

  UploadProfilePictureUseCase(this._profileRepository);

  Future<ApiResponse<Profile>> call(String profileId, String imagePath) {
    return _profileRepository.uploadProfilePicture(profileId, imagePath);
  }
}

/// Search Profiles Use Case
/// Searches for profiles based on various criteria
class SearchProfilesUseCase {
  final ProfileRepository _profileRepository;

  SearchProfilesUseCase(this._profileRepository);

  Future<ApiResponse<List<Profile>>> call({
    String? search,
    String? location,
    List<String>? interests,
    int page = 1,
    int limit = 10,
  }) {
    return _profileRepository.searchProfiles(
      search: search,
      location: location,
      interests: interests,
      page: page,
      limit: limit,
    );
  }
}
