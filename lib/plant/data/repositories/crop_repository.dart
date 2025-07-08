import 'package:ayni/plant/domain/entities/crop.dart';
import 'package:ayni/plant/domain/entities/diagnosis.dart';
import 'package:ayni/plant/data/datasources/crop_data_source.dart';

class CropRepository {
  final CropDataSource _cropDataSource;

  CropRepository({required CropDataSource cropDataSource}) 
      : _cropDataSource = cropDataSource;

  Future<List<Crop>> fetchCrops(int profileId) async {
    final response = await _cropDataSource.fetchCrops(profileId);
    if (response.success && response.data != null) {
      return response.data!.map((model) => Crop.fromModel(model)).toList();
    } else {
      throw Exception(response.error ?? 'Error al obtener cultivos');
    }
  }

  Future<Crop> getCropById(int cropId) async {
    final response = await _cropDataSource.getCropById(cropId);
    if (response.success && response.data != null) {
      return Crop.fromModel(response.data!);
    } else {
      throw Exception(response.error ?? 'Error al obtener cultivo');
    }
  }

  Future<Crop> createCrop(Map<String, dynamic> cropData) async {
    final response = await _cropDataSource.createCrop(cropData);
    if (response.success && response.data != null) {
      return Crop.fromModel(response.data!);
    } else {
      throw Exception(response.error ?? 'Error al crear cultivo');
    }
  }

  Future<Crop> updateCropStatus(int cropId, Map<String, dynamic> statusData) async {
    final response = await _cropDataSource.updateCropStatus(cropId, statusData);
    if (response.success && response.data != null) {
      return Crop.fromModel(response.data!);
    } else {
      throw Exception(response.error ?? 'Error al actualizar estado del cultivo');
    }
  }

  Future<List<Crop>> getCropsWithActiveDisease(int profileId) async {
    final response = await _cropDataSource.getCropsWithActiveDisease(profileId);
    if (response.success && response.data != null) {
      return response.data!.map((model) => Crop.fromModel(model)).toList();
    } else {
      throw Exception(response.error ?? 'Error al obtener cultivos con enfermedades');
    }
  }

  // Métodos para diagnósticos
  Future<List<Diagnosis>> getDiagnosesByCropId(int cropId) async {
    final response = await _cropDataSource.getDiagnosesByCropId(cropId);
    if (response.success && response.data != null) {
      return response.data!.map((model) => Diagnosis.fromModel(model)).toList();
    } else {
      throw Exception(response.error ?? 'Error al obtener diagnósticos del cultivo');
    }
  }

  Future<Diagnosis> startDiagnosis(Map<String, dynamic> diagnosisData) async {
    final response = await _cropDataSource.startDiagnosis(diagnosisData);
    if (response.success && response.data != null) {
      return Diagnosis.fromModel(response.data!);
    } else {
      throw Exception(response.error ?? 'Error al iniciar diagnóstico');
    }
  }

  Future<Diagnosis> getDiagnosisById(int diagnosisId) async {
    final response = await _cropDataSource.getDiagnosisById(diagnosisId);
    if (response.success && response.data != null) {
      return Diagnosis.fromModel(response.data!);
    } else {
      throw Exception(response.error ?? 'Error al obtener diagnóstico');
    }
  }

  Future<List<Diagnosis>> getDiagnosesByProfileId(int profileId) async {
    final response = await _cropDataSource.getDiagnosesByProfileId(profileId);
    if (response.success && response.data != null) {
      return response.data!.map((model) => Diagnosis.fromModel(model)).toList();
    } else {
      throw Exception(response.error ?? 'Error al obtener diagnósticos del perfil');
    }
  }

  Future<List<Diagnosis>> getPendingDiagnoses() async {
    final response = await _cropDataSource.getPendingDiagnoses();
    if (response.success && response.data != null) {
      return response.data!.map((model) => Diagnosis.fromModel(model)).toList();
    } else {
      throw Exception(response.error ?? 'Error al obtener diagnósticos pendientes');
    }
  }

  Future<Map<String, dynamic>> getDetectionServiceStatus() async {
    final response = await _cropDataSource.getDetectionServiceStatus();
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al obtener estado del servicio de detección');
    }
  }
}
