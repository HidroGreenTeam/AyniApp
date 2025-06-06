import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ayni/profile/domain/usecases/profile_usecases.dart';
import 'package:ayni/profile/domain/repositories/profile_repository.dart';
import 'package:ayni/profile/domain/entities/profile.dart';
import 'package:ayni/profile/data/models/profile_models.dart';
import 'package:ayni/core/utils/api_response.dart';

import 'profile_usecases_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  group('Profile Use Cases', () {
    late MockProfileRepository mockRepository;
    late GetCurrentProfileUseCase getCurrentProfileUseCase;
    late GetProfileUseCase getProfileUseCase;
    late CreateProfileUseCase createProfileUseCase;
    late UpdateProfileUseCase updateProfileUseCase;
    late DeleteProfileUseCase deleteProfileUseCase;
    late UploadProfilePictureUseCase uploadProfilePictureUseCase;
    late SearchProfilesUseCase searchProfilesUseCase;
    late GetCachedProfileUseCase getCachedProfileUseCase;
    late ClearProfileCacheUseCase clearProfileCacheUseCase;

    setUp(() {
      mockRepository = MockProfileRepository();
      getCurrentProfileUseCase = GetCurrentProfileUseCase(mockRepository);
      getProfileUseCase = GetProfileUseCase(mockRepository);
      createProfileUseCase = CreateProfileUseCase(mockRepository);
      updateProfileUseCase = UpdateProfileUseCase(mockRepository);
      deleteProfileUseCase = DeleteProfileUseCase(mockRepository);
      uploadProfilePictureUseCase = UploadProfilePictureUseCase(mockRepository);
      searchProfilesUseCase = SearchProfilesUseCase(mockRepository);
      getCachedProfileUseCase = GetCachedProfileUseCase(mockRepository);
      clearProfileCacheUseCase = ClearProfileCacheUseCase(mockRepository);
    });

    final mockProfile = Profile(
      id: '1',
      userId: 'user1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john@example.com',
      phoneNumber: '+1234567890',
      location: 'Lima, Peru',
      bio: 'Test bio',
      interests: ['agriculture', 'sustainability'],
      profilePicture: 'https://example.com/pic.jpg',
      isVerified: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    group('GetCurrentProfileUseCase', () {
      test('should return current profile when repository call is successful', () async {
        // Arrange
        when(mockRepository.getCurrentProfile())
            .thenAnswer((_) async => ApiResponse.success(mockProfile));

        // Act
        final result = await getCurrentProfileUseCase();        // Assert
        expect(result, isA<ApiResponse<Profile>>());
        expect(result.success, isTrue);
        expect(result.data, equals(mockProfile));
        verify(mockRepository.getCurrentProfile()).called(1);
      });

      test('should return error when repository call fails', () async {
        // Arrange
        when(mockRepository.getCurrentProfile())
            .thenAnswer((_) async => ApiResponse.error('Network error'));

        // Act
        final result = await getCurrentProfileUseCase();        // Assert
        expect(result, isA<ApiResponse<Profile>>());
        expect(result.success, isFalse);
        expect(result.error, equals('Network error'));
      });
    });

    group('GetProfileUseCase', () {
      const userId = 'user123';

      test('should return profile by id when repository call is successful', () async {
        // Arrange
        when(mockRepository.getProfileById(userId))
            .thenAnswer((_) async => ApiResponse.success(mockProfile));

        // Act
        final result = await getProfileUseCase(userId);        // Assert
        expect(result, isA<ApiResponse<Profile>>());
        expect(result.success, isTrue);
        expect(result.data, equals(mockProfile));
        verify(mockRepository.getProfileById(userId)).called(1);
      });
    });

    group('CreateProfileUseCase', () {
      final createRequest = CreateProfileRequest(
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        bio: 'Test bio',
      );

      test('should create profile when repository call is successful', () async {
        // Arrange
        when(mockRepository.createProfile(createRequest))
            .thenAnswer((_) async => ApiResponse.success(mockProfile));

        // Act
        final result = await createProfileUseCase(createRequest);

        // Assert
        expect(result, isA<ApiResponse<Profile>>());
        expect(result.data, equals(mockProfile));
        verify(mockRepository.createProfile(createRequest)).called(1);
      });
    });

    group('UpdateProfileUseCase', () {
      const profileId = '1';
      final updateRequest = UpdateProfileRequest(
        firstName: 'John Updated',
        bio: 'Updated bio',
      );

      test('should update profile when repository call is successful', () async {
        // Arrange
        when(mockRepository.updateProfile(profileId, updateRequest))
            .thenAnswer((_) async => ApiResponse.success(mockProfile));

        // Act
        final result = await updateProfileUseCase(profileId, updateRequest);

        // Assert
        expect(result, isA<ApiResponse<Profile>>());
        expect(result.data, equals(mockProfile));
        verify(mockRepository.updateProfile(profileId, updateRequest)).called(1);
      });
    });

    group('DeleteProfileUseCase', () {
      const profileId = '1';

      test('should delete profile when repository call is successful', () async {
        // Arrange
        when(mockRepository.deleteProfile(profileId))
            .thenAnswer((_) async => ApiResponse.success(null));

        // Act
        final result = await deleteProfileUseCase(profileId);        // Assert
        expect(result, isA<ApiResponse<void>>());
        expect(result.success, isTrue);
        verify(mockRepository.deleteProfile(profileId)).called(1);
      });
    });

    group('UploadProfilePictureUseCase', () {
      const profileId = '1';
      const imagePath = '/path/to/image.jpg';

      test('should upload profile picture when repository call is successful', () async {
        // Arrange
        when(mockRepository.uploadProfilePicture(profileId, imagePath))
            .thenAnswer((_) async => ApiResponse.success(mockProfile));

        // Act
        final result = await uploadProfilePictureUseCase(profileId, imagePath);        // Assert
        expect(result, isA<ApiResponse<Profile>>());
        expect(result.success, isTrue);
        expect(result.data, equals(mockProfile));
        verify(mockRepository.uploadProfilePicture(profileId, imagePath)).called(1);
      });
    });

    group('SearchProfilesUseCase', () {
      final mockProfiles = [mockProfile];

      test('should search profiles when repository call is successful', () async {
        // Arrange
        when(mockRepository.searchProfiles(
          search: 'John',
          page: 1,
          limit: 10,
        )).thenAnswer((_) async => ApiResponse.success(mockProfiles));

        // Act
        final result = await searchProfilesUseCase(
          search: 'John',
          page: 1,
          limit: 10,
        );        // Assert
        expect(result, isA<ApiResponse<List<Profile>>>());
        expect(result.success, isTrue);
        expect(result.data, equals(mockProfiles));
        verify(mockRepository.searchProfiles(
          search: 'John',
          page: 1,
          limit: 10,
        )).called(1);
      });
    });

    group('GetCachedProfileUseCase', () {
      test('should return cached profile when available', () {
        // Arrange
        when(mockRepository.getCachedProfile()).thenReturn(mockProfile);

        // Act
        final result = getCachedProfileUseCase();

        // Assert
        expect(result, equals(mockProfile));
        verify(mockRepository.getCachedProfile()).called(1);
      });

      test('should return null when no cached profile available', () {
        // Arrange
        when(mockRepository.getCachedProfile()).thenReturn(null);

        // Act
        final result = getCachedProfileUseCase();

        // Assert
        expect(result, isNull);
        verify(mockRepository.getCachedProfile()).called(1);
      });
    });

    group('ClearProfileCacheUseCase', () {
      test('should clear profile cache when called', () {
        // Act
        clearProfileCacheUseCase();

        // Assert
        verify(mockRepository.clearCache()).called(1);
      });
    });
  });
}
