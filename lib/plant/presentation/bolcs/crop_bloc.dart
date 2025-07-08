import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ayni/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:ayni/plant/domain/entities/crop.dart';
import 'package:ayni/plant/data/repositories/crop_repository.dart';

// Events
abstract class CropEvent extends Equatable {
  const CropEvent();
  @override
  List<Object?> get props => [];
}

class FetchCrops extends CropEvent {}

class AddCrop extends CropEvent {
  final Map<String, dynamic> cropData;
  const AddCrop(this.cropData);
  @override
  List<Object?> get props => [cropData];
}

class UpdateCropStatus extends CropEvent {
  final int cropId;
  final Map<String, dynamic> statusData;
  const UpdateCropStatus(this.cropId, this.statusData);
  @override
  List<Object?> get props => [cropId, statusData];
}

class GetCropsWithActiveDisease extends CropEvent {}



// States
enum CropStatus { initial, loading, loaded, error }

class CropState extends Equatable {
  final CropStatus status;
  final List<Crop> crops;
  final List<Crop> diseasedCrops;
  final String? errorMessage;

  const CropState({
    this.status = CropStatus.initial,
    this.crops = const [],
    this.diseasedCrops = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, crops, diseasedCrops, errorMessage];

  CropState copyWith({
    CropStatus? status,
    List<Crop>? crops,
    List<Crop>? diseasedCrops,
    String? errorMessage,
  }) {
    return CropState(
      status: status ?? this.status,
      crops: crops ?? this.crops,
      diseasedCrops: diseasedCrops ?? this.diseasedCrops,
      errorMessage: errorMessage,
    );
  }
}

class CropBloc extends Bloc<CropEvent, CropState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CropRepository _cropRepository;

  CropBloc(this._getCurrentUserUseCase, this._cropRepository) : super(const CropState()) {
    on<FetchCrops>(_onFetchCrops);
    on<AddCrop>(_onAddCrop);
    on<UpdateCropStatus>(_onUpdateCropStatus);
    on<GetCropsWithActiveDisease>(_onGetCropsWithActiveDisease);
  }

  Future<void> _onFetchCrops(FetchCrops event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final user = _getCurrentUserUseCase();
      final int? profileId = user?.id != null ? int.tryParse(user!.id) : null;
      if (profileId != null) {
        final crops = await _cropRepository.fetchCrops(profileId);
        emit(state.copyWith(status: CropStatus.loaded, crops: crops));
      } else {
        emit(state.copyWith(status: CropStatus.error, errorMessage: 'Profile ID es nulo'));
      }
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddCrop(AddCrop event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final user = _getCurrentUserUseCase();
      final int? profileId = user?.id != null ? int.tryParse(user!.id) : null;
      if (profileId == null) throw Exception('Profile ID es nulo');
      
      final cropData = Map<String, dynamic>.from(event.cropData);
      cropData['profileId'] = profileId;
      
      final newCrop = await _cropRepository.createCrop(cropData);
      
      final updatedCrops = List<Crop>.from(state.crops)..add(newCrop);
      emit(state.copyWith(status: CropStatus.loaded, crops: updatedCrops));
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCropStatus(UpdateCropStatus event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final updatedCrop = await _cropRepository.updateCropStatus(event.cropId, event.statusData);
      
      final updatedCrops = state.crops.map((c) => c.id == event.cropId ? updatedCrop : c).toList();
      emit(state.copyWith(status: CropStatus.loaded, crops: updatedCrops));
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onGetCropsWithActiveDisease(GetCropsWithActiveDisease event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final user = _getCurrentUserUseCase();
      final int? profileId = user?.id != null ? int.tryParse(user!.id) : null;
      if (profileId != null) {
        final diseasedCrops = await _cropRepository.getCropsWithActiveDisease(profileId);
        emit(state.copyWith(status: CropStatus.loaded, diseasedCrops: diseasedCrops));
      } else {
        emit(state.copyWith(status: CropStatus.error, errorMessage: 'Profile ID es nulo'));
      }
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }
}