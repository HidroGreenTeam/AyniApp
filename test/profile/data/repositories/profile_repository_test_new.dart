import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ayni/profile/data/repositories/profile_repository_impl.dart';
import 'package:ayni/profile/data/datasources/profile_data_source.dart';
import 'package:ayni/profile/domain/entities/profile.dart';
import 'package:ayni/profile/data/models/profile_models.dart';
import 'package:ayni/core/utils/api_response.dart';
import 'package:ayni/core/services/storage_service.dart';

import 'profile_repository_test.mocks.dart';

@GenerateMocks([ProfileDataSource, StorageService])
void main() {
  group('ProfileRepositoryImpl', () {
    late ProfileRepositoryImpl repository;
    late MockProfileDataSource mockDataSource;
    late MockStorageService mockStorageService;

    setUp(() {
      mockDataSource = MockProfileDataSource();
      mockStorageService = MockStorageService();
      repository = ProfileRepositoryImpl(mockDataSource, mockStorageService);
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

    final mockProfileModel = ProfileModel(
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

    group('getCurrentProfile', () {
      test('should return current profile from data source when call is successful', () async {
        // Arrange
        when(mockDataSource.getCurrentProfile())
            .thenAnswer((_) async => ApiResponse.success(mockProfileModel));

        // Act
        final result = await repository.getCurrentProfile();        // Assert
        expect(result.success, true);
        expect(result.data, isA<Profile>());
        expect(result.data!.id, equals(mockProfile.id));
        verify(mockDataSource.getCurrentProfile()).called(1);
      });

      test('should return error when data source call fails', () async {
        // Arrange
        when(mockDataSource.getCurrentProfile())
            .thenAnswer((_) async => ApiResponse.error('Network error'));

        // Act
        final result = await repository.getCurrentProfile();        // Assert
        expect(result.success, false);
        expect(result.error, equals('Network error'));
        verify(mockDataSource.getCurrentProfile()).called(1);
      });
    });

    group('getProfileById', () {
      const userId = 'user123';

      test('should return profile by id from data source when call is successful', () async {
        // Arrange
        when(mockDataSource.getProfileById(userId))
            .thenAnswer((_) async => ApiResponse.success(mockProfileModel));

        // Act
        final result = await repository.getProfileById(userId);        // Assert
        expect(result.success, true);
        expect(result.data, isA<Profile>());
        expect(result.data!.id, equals(mockProfile.id));
        verify(mockDataSource.getProfileById(userId)).called(1);
      });
    });

    group('createProfile', () {
      final createRequest = CreateProfileRequest(
        firstName: 'John',
        lastName: 'Doe',
        phoneNumber: '+1234567890',
        bio: 'Test bio',
      );

      test('should create profile via data source when call is successful', () async {
        // Arrange
        when(mockDataSource.createProfile(createRequest))
            .thenAnswer((_) async => ApiResponse.success(mockProfileModel));

        // Act
        final result = await repository.createProfile(createRequest);        // Assert
        expect(result.success, true);
        expect(result.data, isA<Profile>());
        expect(result.data!.firstName, equals('John'));
        verify(mockDataSource.createProfile(createRequest)).called(1);
      });
    });

    group('updateProfile', () {
      const profileId = '1';
      final updateRequest = UpdateProfileRequest(
        firstName: 'John Updated',
        bio: 'Updated bio',
      );

      test('should update profile via data source when call is successful', () async {
        // Arrange
        when(mockDataSource.updateProfile(profileId, updateRequest))
            .thenAnswer((_) async => ApiResponse.success(mockProfileModel));

        // Act
        final result = await repository.updateProfile(profileId, updateRequest);        // Assert
        expect(result.success, true);
        expect(result.data, isA<Profile>());
        verify(mockDataSource.updateProfile(profileId, updateRequest)).called(1);
      });
    });

    group('deleteProfile', () {
      const profileId = '1';

      test('should delete profile via data source when call is successful', () async {
        // Arrange
        when(mockDataSource.deleteProfile(profileId))
            .thenAnswer((_) async => ApiResponse.success(null));

        // Act
        final result = await repository.deleteProfile(profileId);        // Assert
        expect(result.success, true);
        verify(mockDataSource.deleteProfile(profileId)).called(1);
      });
    });

    group('uploadProfilePicture', () {
      const profileId = '1';
      const imagePath = '/path/to/image.jpg';

      test('should upload profile picture via data source when call is successful', () async {
        // Arrange
        when(mockDataSource.uploadProfilePicture(profileId, imagePath))
            .thenAnswer((_) async => ApiResponse.success(mockProfileModel));

        // Act
        final result = await repository.uploadProfilePicture(profileId, imagePath);        // Assert
        expect(result.success, true);
        expect(result.data, isA<Profile>());
        verify(mockDataSource.uploadProfilePicture(profileId, imagePath)).called(1);
      });
    });

    group('searchProfiles', () {
      final mockProfileModels = [mockProfileModel];

      test('should search profiles via data source when call is successful', () async {
        // Arrange
        when(mockDataSource.searchProfiles(
          search: 'John',
          page: 1,
          limit: 10,
        )).thenAnswer((_) async => ApiResponse.success(mockProfileModels));

        // Act
        final result = await repository.searchProfiles(
          search: 'John',
          page: 1,
          limit: 10,
        );        // Assert
        expect(result.success, true);
        expect(result.data, isA<List<Profile>>());
        expect(result.data!.length, equals(1));
        verify(mockDataSource.searchProfiles(
          search: 'John',
          page: 1,
          limit: 10,
        )).called(1);
      });
    });

    group('Cache management', () {
      test('should store and retrieve cached profile', () {
        // Act
        repository.updateCache(mockProfile);
        final result = repository.getCachedProfile();

        // Assert
        expect(result, equals(mockProfile));
      });

      test('should clear cached profile', () {
        // Arrange
        repository.updateCache(mockProfile);

        // Act
        repository.clearCache();
        final result = repository.getCachedProfile();

        // Assert
        expect(result, isNull);
      });

      test('should return null when no cached profile exists', () {
        // Act
        final result = repository.getCachedProfile();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
