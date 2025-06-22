import 'dart:io';
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
  final File? imageFile;
  const AddCrop(this.cropData, {this.imageFile});
  @override
  List<Object?> get props => [cropData, imageFile];
}

class UpdateCrop extends CropEvent {
  final int cropId;
  final Map<String, dynamic> cropData;
  final File? imageFile;
  const UpdateCrop(this.cropId, this.cropData, {this.imageFile});
  @override
  List<Object?> get props => [cropId, cropData, imageFile];
}

class DeleteCrop extends CropEvent {
  final int cropId;
  const DeleteCrop(this.cropId);
  @override
  List<Object?> get props => [cropId];
}

class UpdateCropImage extends CropEvent {
  final int cropId;
  final File imageFile;
  const UpdateCropImage(this.cropId, this.imageFile);
  @override
  List<Object?> get props => [cropId, imageFile];
}

class DeleteCropImage extends CropEvent {
  final int cropId;
  const DeleteCropImage(this.cropId);
  @override
  List<Object?> get props => [cropId];
}

// States
enum CropStatus { initial, loading, loaded, error }

class CropState extends Equatable {
  final CropStatus status;
  final List<Crop> crops;
  final String? errorMessage;

  const CropState({
    this.status = CropStatus.initial,
    this.crops = const [],
    this.errorMessage,
  });

  @override
  List<Object?> get props => [status, crops, errorMessage];

  CropState copyWith({
    CropStatus? status,
    List<Crop>? crops,
    String? errorMessage,
  }) {
    return CropState(
      status: status ?? this.status,
      crops: crops ?? this.crops,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CropBloc extends Bloc<CropEvent, CropState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final CropRepository _cropRepository;

  CropBloc(this._getCurrentUserUseCase, this._cropRepository) : super(const CropState()) {
    on<FetchCrops>(_onFetchCrops);
    on<AddCrop>(_onAddCrop);
    on<UpdateCrop>(_onUpdateCrop);
    on<DeleteCrop>(_onDeleteCrop);
    on<UpdateCropImage>(_onUpdateCropImage);
    on<DeleteCropImage>(_onDeleteCropImage);
  }

  Future<void> _onFetchCrops(FetchCrops event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final user = _getCurrentUserUseCase();
      final int? farmerId = user?.id != null ? int.tryParse(user!.id) : null;
      if (farmerId != null) {
        final crops = await _cropRepository.fetchCrops(farmerId);
        emit(state.copyWith(status: CropStatus.loaded, crops: crops));
      } else {
        emit(state.copyWith(status: CropStatus.error, errorMessage: 'Farmer ID is null'));
      }
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddCrop(AddCrop event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final user = _getCurrentUserUseCase();
      final int? farmerId = user?.id != null ? int.tryParse(user!.id) : null;
      if (farmerId == null) throw Exception('Farmer ID is null');
      
      final cropData = Map<String, dynamic>.from(event.cropData);
      cropData['farmerId'] = farmerId;
      
      final newCrop = await _cropRepository.createCrop(cropData);
      
      if (event.imageFile != null) {
        await _cropRepository.updateCropImage(newCrop.id, event.imageFile!);
      }
      
      final updatedCrops = List<Crop>.from(state.crops)..add(newCrop);
      emit(state.copyWith(status: CropStatus.loaded, crops: updatedCrops));
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCrop(UpdateCrop event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final updatedCrop = await _cropRepository.updateCrop(event.cropId, event.cropData);
      
      if (event.imageFile != null) {
        await _cropRepository.updateCropImage(event.cropId, event.imageFile!);
      }
      
      final updatedCrops = state.crops.map((c) => c.id == event.cropId ? updatedCrop : c).toList();
      emit(state.copyWith(status: CropStatus.loaded, crops: updatedCrops));
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCrop(DeleteCrop event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      await _cropRepository.deleteCrop(event.cropId);
      final updatedCrops = state.crops.where((c) => c.id != event.cropId).toList();
      emit(state.copyWith(status: CropStatus.loaded, crops: updatedCrops));
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateCropImage(UpdateCropImage event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final updatedCrop = await _cropRepository.updateCropImage(event.cropId, event.imageFile);
      final updatedCrops = state.crops.map((c) => c.id == event.cropId ? updatedCrop : c).toList();
      emit(state.copyWith(status: CropStatus.loaded, crops: updatedCrops));
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteCropImage(DeleteCropImage event, Emitter<CropState> emit) async {
    emit(state.copyWith(status: CropStatus.loading));
    try {
      final updatedCrop = await _cropRepository.deleteCropImage(event.cropId);
      final updatedCrops = state.crops.map((c) => c.id == event.cropId ? updatedCrop : c).toList();
      emit(state.copyWith(status: CropStatus.loaded, crops: updatedCrops));
    } catch (e) {
      emit(state.copyWith(status: CropStatus.error, errorMessage: e.toString()));
    }
  }
}