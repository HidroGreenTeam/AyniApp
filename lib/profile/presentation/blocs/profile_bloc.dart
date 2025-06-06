import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/profile_models.dart';
import '../../domain/entities/profile.dart';
import '../viewmodels/profile_viewmodel.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadCurrent extends ProfileEvent {
  const ProfileLoadCurrent();
}

class ProfileLoadById extends ProfileEvent {
  final String userId;
  
  const ProfileLoadById(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

class ProfileCreate extends ProfileEvent {
  final CreateProfileRequest request;
  
  const ProfileCreate(this.request);
  
  @override
  List<Object?> get props => [request];
}

class ProfileUpdate extends ProfileEvent {
  final String profileId;
  final UpdateProfileRequest request;
  
  const ProfileUpdate(this.profileId, this.request);
  
  @override
  List<Object?> get props => [profileId, request];
}

class ProfileDelete extends ProfileEvent {
  final String profileId;
  
  const ProfileDelete(this.profileId);
  
  @override
  List<Object?> get props => [profileId];
}

class ProfileUploadPicture extends ProfileEvent {
  final String profileId;
  final String imagePath;
  
  const ProfileUploadPicture(this.profileId, this.imagePath);
  
  @override
  List<Object?> get props => [profileId, imagePath];
}

class ProfileSearch extends ProfileEvent {
  final String? search;
  final String? location;
  final List<String>? interests;
  final int page;
  final int limit;
  
  const ProfileSearch({
    this.search,
    this.location,
    this.interests,
    this.page = 1,
    this.limit = 10,
  });
  
  @override
  List<Object?> get props => [search, location, interests, page, limit];
}

class ProfileLoadCached extends ProfileEvent {
  const ProfileLoadCached();
}

class ProfileClearCache extends ProfileEvent {
  const ProfileClearCache();
}

// States
enum ProfileStatus { 
  initial, 
  loading, 
  loaded, 
  creating, 
  created, 
  updating, 
  updated, 
  deleting, 
  deleted, 
  uploading, 
  uploaded, 
  searching, 
  searchCompleted,
  error 
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final Profile? currentProfile;
  final Profile? selectedProfile;
  final List<Profile> searchResults;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;

  const ProfileState({
    required this.status,
    this.currentProfile,
    this.selectedProfile,
    this.searchResults = const [],
    this.errorMessage,
    this.hasMore = false,
    this.currentPage = 1,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      status: ProfileStatus.initial,
    );
  }

  ProfileState copyWith({
    ProfileStatus? status,
    Profile? currentProfile,
    Profile? selectedProfile,
    List<Profile>? searchResults,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      currentProfile: currentProfile ?? this.currentProfile,
      selectedProfile: selectedProfile ?? this.selectedProfile,
      searchResults: searchResults ?? this.searchResults,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    currentProfile, 
    selectedProfile, 
    searchResults, 
    errorMessage, 
    hasMore, 
    currentPage
  ];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileViewModel _profileViewModel;

  ProfileBloc({required ProfileViewModel profileViewModel})
      : _profileViewModel = profileViewModel,
        super(ProfileState.initial()) {
    on<ProfileLoadCurrent>(_onLoadCurrent);
    on<ProfileLoadById>(_onLoadById);
    on<ProfileCreate>(_onCreate);
    on<ProfileUpdate>(_onUpdate);
    on<ProfileDelete>(_onDelete);
    on<ProfileUploadPicture>(_onUploadPicture);
    on<ProfileSearch>(_onSearch);
    on<ProfileLoadCached>(_onLoadCached);
    on<ProfileClearCache>(_onClearCache);
  }

  Future<void> _onLoadCurrent(ProfileLoadCurrent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    try {
      final response = await _profileViewModel.getCurrentProfile();
      
      if (response.success && response.data != null) {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          currentProfile: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: response.error ?? 'Failed to load profile',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadById(ProfileLoadById event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    
    try {
      final response = await _profileViewModel.getProfile(event.userId);
      
      if (response.success && response.data != null) {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          selectedProfile: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: response.error ?? 'Failed to load profile',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreate(ProfileCreate event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.creating));
    
    try {
      final response = await _profileViewModel.createProfile(event.request);
      
      if (response.success && response.data != null) {
        emit(state.copyWith(
          status: ProfileStatus.created,
          currentProfile: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: response.error ?? 'Failed to create profile',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdate(ProfileUpdate event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.updating));
    
    try {
      final response = await _profileViewModel.updateProfile(event.profileId, event.request);
      
      if (response.success && response.data != null) {
        emit(state.copyWith(
          status: ProfileStatus.updated,
          currentProfile: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: response.error ?? 'Failed to update profile',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(ProfileDelete event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.deleting));
    
    try {
      final response = await _profileViewModel.deleteProfile(event.profileId);
      
      if (response.success) {
        emit(state.copyWith(
          status: ProfileStatus.deleted,
          currentProfile: null,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: response.error ?? 'Failed to delete profile',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUploadPicture(ProfileUploadPicture event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.uploading));
    
    try {
      final response = await _profileViewModel.uploadProfilePicture(event.profileId, event.imagePath);
      
      if (response.success && response.data != null) {
        emit(state.copyWith(
          status: ProfileStatus.uploaded,
          currentProfile: response.data,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: response.error ?? 'Failed to upload profile picture',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSearch(ProfileSearch event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.searching));
    
    try {
      final response = await _profileViewModel.searchProfiles(
        search: event.search,
        location: event.location,
        interests: event.interests,
        page: event.page,
        limit: event.limit,
      );
      
      if (response.success && response.data != null) {
        final results = event.page == 1 
            ? response.data! 
            : [...state.searchResults, ...response.data!];
            
        emit(state.copyWith(
          status: ProfileStatus.searchCompleted,
          searchResults: results,
          hasMore: response.data!.length == event.limit,
          currentPage: event.page,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: response.error ?? 'Failed to search profiles',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onLoadCached(ProfileLoadCached event, Emitter<ProfileState> emit) {
    try {
      final cachedProfile = _profileViewModel.getCachedProfile();
      if (cachedProfile != null) {
        emit(state.copyWith(
          status: ProfileStatus.loaded,
          currentProfile: cachedProfile,
        ));
      } else {
        emit(state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'No cached profile found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  Future<void> _onClearCache(ProfileClearCache event, Emitter<ProfileState> emit) async {
    try {
      _profileViewModel.clearCache();
      emit(state.copyWith(
        status: ProfileStatus.initial,
        currentProfile: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
