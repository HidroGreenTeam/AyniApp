import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:ayni/profile/presentation/blocs/profile_bloc.dart';
import 'package:ayni/profile/presentation/viewmodels/profile_viewmodel.dart';
import 'package:ayni/profile/domain/entities/profile.dart';
import 'package:ayni/core/utils/api_response.dart';

import 'profile_bloc_test.mocks.dart';

@GenerateMocks([ProfileViewModel])
void main() {
  group('ProfileBloc', () {
    late ProfileBloc profileBloc;
    late MockProfileViewModel mockProfileViewModel;

    setUp(() {
      mockProfileViewModel = MockProfileViewModel();
      profileBloc = ProfileBloc(profileViewModel: mockProfileViewModel);
    });

    tearDown(() {
      profileBloc.close();
    });

    test('initial state is ProfileState.initial', () {
      expect(profileBloc.state, equals(ProfileState.initial()));
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

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, loaded] when current profile loads successfully',
      build: () {
        when(mockProfileViewModel.getCurrentProfile())
            .thenAnswer((_) async => ApiResponse.success(mockProfile));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const ProfileLoadCurrent()),
      expect: () => [
        ProfileState.initial().copyWith(status: ProfileStatus.loading),
        ProfileState.initial().copyWith(
          status: ProfileStatus.loaded,
          currentProfile: mockProfile,
        ),
      ],
      verify: (_) {
        verify(mockProfileViewModel.getCurrentProfile()).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, error] when current profile loading fails',
      build: () {
        when(mockProfileViewModel.getCurrentProfile())
            .thenAnswer((_) async => ApiResponse.error('Failed to load profile'));
        return profileBloc;
      },
      act: (bloc) => bloc.add(const ProfileLoadCurrent()),
      expect: () => [
        ProfileState.initial().copyWith(status: ProfileStatus.loading),
        ProfileState.initial().copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Failed to load profile',
        ),
      ],
    );
  });
}