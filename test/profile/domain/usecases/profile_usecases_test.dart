import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ayni/profile/domain/usecases/profile_usecases.dart';
import 'package:ayni/profile/domain/repositories/profile_repository.dart';
import 'package:ayni/profile/domain/entities/profile.dart';
import 'package:ayni/core/utils/api_response.dart';

import 'profile_usecases_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  group('Profile Use Cases', () {
    late MockProfileRepository mockRepository;
    late GetCurrentProfileUseCase getCurrentProfileUseCase;

    setUp(() {
      mockRepository = MockProfileRepository();
      getCurrentProfileUseCase = GetCurrentProfileUseCase(mockRepository);
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

    test('should return current profile when repository call is successful', () async {
      // Arrange
      when(mockRepository.getCurrentProfile())
          .thenAnswer((_) async => ApiResponse.success(mockProfile));

      // Act
      final result = await getCurrentProfileUseCase();

      // Assert
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
      final result = await getCurrentProfileUseCase();

      // Assert
      expect(result, isA<ApiResponse<Profile>>());
      expect(result.success, isFalse);
      expect(result.error, equals('Network error'));
    });
  });
}