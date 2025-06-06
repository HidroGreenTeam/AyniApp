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

    test('should return current profile from data source when call is successful', () async {
      // Arrange
      when(mockDataSource.getCurrentProfile())
          .thenAnswer((_) async => ApiResponse.success(mockProfileModel));

      // Act
      final result = await repository.getCurrentProfile();

      // Assert
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
      final result = await repository.getCurrentProfile();

      // Assert
      expect(result.success, false);
      expect(result.error, equals('Network error'));
      verify(mockDataSource.getCurrentProfile()).called(1);
    });
  });
}