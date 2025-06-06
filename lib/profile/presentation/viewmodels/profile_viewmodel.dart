import '../../../core/utils/api_response.dart';
import '../../data/models/profile_models.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/profile_usecases.dart';

/// ProfileViewModel following MVVM pattern
/// Acts as an intermediary between View (BLoC) and Model (Use Cases)
class ProfileViewModel {
  final GetProfileUseCase _getProfileUseCase;
  final GetCurrentProfileUseCase _getCurrentProfileUseCase;
  final CreateProfileUseCase _createProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final DeleteProfileUseCase _deleteProfileUseCase;  final UploadProfilePictureUseCase _uploadProfilePictureUseCase;
  final SearchProfilesUseCase _searchProfilesUseCase;
  final GetCachedProfileUseCase _getCachedProfileUseCase;
  final ClearProfileCacheUseCase _clearProfileCacheUseCase;

  ProfileViewModel({
    required GetProfileUseCase getProfileUseCase,
    required GetCurrentProfileUseCase getCurrentProfileUseCase,
    required CreateProfileUseCase createProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required DeleteProfileUseCase deleteProfileUseCase,    required UploadProfilePictureUseCase uploadProfilePictureUseCase,
    required SearchProfilesUseCase searchProfilesUseCase,
    required GetCachedProfileUseCase getCachedProfileUseCase,
    required ClearProfileCacheUseCase clearProfileCacheUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _getCurrentProfileUseCase = getCurrentProfileUseCase,
       _createProfileUseCase = createProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _deleteProfileUseCase = deleteProfileUseCase,       _uploadProfilePictureUseCase = uploadProfilePictureUseCase,
       _searchProfilesUseCase = searchProfilesUseCase,
       _getCachedProfileUseCase = getCachedProfileUseCase,
       _clearProfileCacheUseCase = clearProfileCacheUseCase;  /// Get profile by user ID
  Future<ApiResponse<Profile>> getProfile(String userId) {
    return _getProfileUseCase.call(userId);
  }

  /// Get current user's profile
  Future<ApiResponse<Profile>> getCurrentProfile() {
    return _getCurrentProfileUseCase.call();
  }

  /// Create a new profile
  Future<ApiResponse<Profile>> createProfile(CreateProfileRequest request) {
    return _createProfileUseCase.call(request);
  }

  /// Update existing profile
  Future<ApiResponse<Profile>> updateProfile(String profileId, UpdateProfileRequest request) {
    return _updateProfileUseCase.call(profileId, request);
  }

  /// Delete profile
  Future<ApiResponse<void>> deleteProfile(String profileId) {
    return _deleteProfileUseCase.call(profileId);
  }

  /// Upload profile picture
  Future<ApiResponse<Profile>> uploadProfilePicture(String profileId, String imagePath) {
    return _uploadProfilePictureUseCase.call(profileId, imagePath);
  }

  /// Search profiles with filters
  Future<ApiResponse<List<Profile>>> searchProfiles({
    String? search,
    String? location,
    List<String>? interests,
    int page = 1,
    int limit = 10,
  }) {
    return _searchProfilesUseCase.call(
      search: search,
      location: location,
      interests: interests,
      page: page,
      limit: limit,
    );
  }
  /// Get cached profile (offline mode)
  Profile? getCachedProfile() {
    return _getCachedProfileUseCase.call();
  }
  
  /// Clear profile cache
  void clearCache() {
    _clearProfileCacheUseCase.call();
  }

  /// Validate profile data
  bool validateProfileData({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) {
    if (firstName == null || firstName.trim().isEmpty) {
      return false;
    }
    
    if (lastName == null || lastName.trim().isEmpty) {
      return false;
    }
    
    if (email != null && email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        return false;
      }
    }
    
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
      if (!phoneRegex.hasMatch(phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
        return false;
      }
    }
    
    return true;
  }

  /// Format profile display name
  String getDisplayName(Profile profile) {
    return profile.fullName;
  }

  /// Check if profile is complete
  bool isProfileComplete(Profile profile) {
    return profile.firstName != null &&
           profile.lastName != null &&
           profile.email != null &&
           profile.bio != null &&
           profile.location != null;
  }

  /// Get profile completion percentage
  double getProfileCompletionPercentage(Profile profile) {
    int completedFields = 0;
    const int totalFields = 7; // firstName, lastName, email, phoneNumber, bio, location, profilePicture
    
    if (profile.firstName != null && profile.firstName!.isNotEmpty) completedFields++;
    if (profile.lastName != null && profile.lastName!.isNotEmpty) completedFields++;
    if (profile.email != null && profile.email!.isNotEmpty) completedFields++;
    if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) completedFields++;
    if (profile.bio != null && profile.bio!.isNotEmpty) completedFields++;
    if (profile.location != null && profile.location!.isNotEmpty) completedFields++;
    if (profile.profilePicture != null && profile.profilePicture!.isNotEmpty) completedFields++;
    
    return (completedFields / totalFields) * 100;
  }
}
