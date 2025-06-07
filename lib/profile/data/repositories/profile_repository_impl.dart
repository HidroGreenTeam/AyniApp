import 'dart:convert';
import '../../../core/utils/api_response.dart';
import '../../../core/services/storage_service.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_data_source.dart';
import '../models/profile_models.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _profileDataSource;
  final StorageService _storageService;
  Profile? _cachedProfile;

  ProfileRepositoryImpl(this._profileDataSource, this._storageService);

  Profile _toProfile(ProfileModel model) => Profile(
        id: model.id,
        username: model.username,
        email: model.email,
        phoneNumber: model.phoneNumber,
        imageUrl: model.imageUrl,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  @override
  Future<ApiResponse<Profile>> getCurrentProfile() async {
    try {
      final userIdRaw = _storageService.getString('user_id');
      final userId = userIdRaw?.toString();
      if (userId == null || userId.isEmpty) {
        return ApiResponse.error('No user id found');
      }
      final response = await _profileDataSource.getProfileById(userId);
      if (response.success && response.data != null) {
        _cachedProfile = _toProfile(response.data!);
        await _storageService.setString('current_profile', jsonEncode(response.data!.toJson()));
        return ApiResponse.success(_toProfile(response.data!));
      } else {
        return ApiResponse.error(response.error ?? 'Failed to get current profile');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Profile>> getProfileById(String userId) async {
    try {
      final response = await _profileDataSource.getProfileById(userId);
      if (response.success && response.data != null) {
        await _storageService.setString('profile_$userId', jsonEncode(response.data!.toJson()));
        return ApiResponse.success(_toProfile(response.data!));
      } else {
        return ApiResponse.error(response.error ?? 'Failed to get profile');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Profile>> createProfile(CreateProfileRequest request) async {
    try {
      final response = await _profileDataSource.createProfile(request);
      if (response.success && response.data != null) {
        _cachedProfile = _toProfile(response.data!);
        await _storageService.setString('current_profile', jsonEncode(response.data!.toJson()));
        await _storageService.setString('user_id', response.data!.id.toString());
        return ApiResponse.success(_toProfile(response.data!));
      } else {
        return ApiResponse.error(response.error ?? 'Failed to create profile');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Profile>> updateProfile(String profileId, UpdateProfileRequest request) async {
    try {
      final response = await _profileDataSource.updateProfile(profileId, request);
      if (response.success && response.data != null) {
        _cachedProfile = _toProfile(response.data!);
        await _storageService.setString('current_profile', jsonEncode(response.data!.toJson()));
        return ApiResponse.success(_toProfile(response.data!));
      } else {
        return ApiResponse.error(response.error ?? 'Failed to update profile');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<void>> deleteProfile(String profileId) async {
    try {
      final response = await _profileDataSource.deleteProfile(profileId);
      if (response.success) {
        _cachedProfile = null;
        await _storageService.remove('current_profile');
        await _storageService.remove('user_id');
        return ApiResponse.success(null);
      } else {
        return ApiResponse.error(response.error ?? 'Failed to delete profile');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<Profile>> uploadProfilePicture(String profileId, String imagePath) async {
    try {
      final response = await _profileDataSource.uploadProfilePicture(profileId, imagePath);
      if (response.success && response.data != null) {
        _cachedProfile = _toProfile(response.data!);
        await _storageService.setString('current_profile', jsonEncode(response.data!.toJson()));
        return ApiResponse.success(_toProfile(response.data!));
      } else {
        return ApiResponse.error(response.error ?? 'Failed to upload profile picture');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Profile>>> searchProfiles({
    String? search,
    String? location,
    List<String>? interests,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _profileDataSource.searchProfiles(
        search: search,
        location: location,
        interests: interests,
        page: page,
        limit: limit,
      );
      if (response.success && response.data != null) {
        final profiles = response.data!.map(_toProfile).toList();
        return ApiResponse.success(profiles);
      } else {
        return ApiResponse.error(response.error ?? 'Failed to search profiles');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Profile? getCachedProfile() {
    return _cachedProfile;
  }

  @override
  void updateCache(Profile profile) {
    _cachedProfile = profile;
  }

  @override
  void clearCache() {
    _cachedProfile = null;
  }
}
