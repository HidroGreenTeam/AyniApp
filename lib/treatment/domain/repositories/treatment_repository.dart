import '../../../treatment/data/datasources/treatment_data_source.dart';
import '../../../treatment/data/models/treatment_models.dart';

/// Repositorio para el dominio de tratamientos
class TreatmentRepository {
  final TreatmentDataSource _dataSource;

  TreatmentRepository({required TreatmentDataSource dataSource}) 
      : _dataSource = dataSource;

  /// Actualiza un paso de tratamiento
  Future<TreatmentStepResponse> updateStep(
    int stepId,
    CreateTreatmentStepRequest request,
  ) async {
    final response = await _dataSource.updateStep(stepId, request);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al actualizar paso del tratamiento');
    }
  }

  /// Obtiene pasos de tratamiento por ID de tratamiento
  Future<List<TreatmentStepResponse>> getStepsByTreatmentId(int treatmentId) async {
    final response = await _dataSource.getStepsByTreatmentId(treatmentId);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al obtener pasos del tratamiento');
    }
  }

  /// Crea un nuevo paso de tratamiento
  Future<TreatmentStepResponse> createStep(
    int treatmentId,
    CreateTreatmentStepRequest request,
  ) async {
    final response = await _dataSource.createStep(treatmentId, request);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al crear paso del tratamiento');
    }
  }

  /// Marca un paso como omitido
  Future<TreatmentStepResponse> skipStep(int stepId) async {
    final response = await _dataSource.skipStep(stepId);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al omitir paso del tratamiento');
    }
  }

  /// Marca un paso como completado
  Future<TreatmentStepResponse> completeStep(int stepId) async {
    final response = await _dataSource.completeStep(stepId);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al completar paso del tratamiento');
    }
  }

  /// Obtiene un tratamiento por ID
  Future<TreatmentResponse> getTreatmentById(int treatmentId) async {
    final response = await _dataSource.getTreatmentById(treatmentId);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al obtener tratamiento');
    }
  }

  /// Obtiene pasos con recordatorios
  Future<List<TreatmentStepResponse>> getStepsWithReminders() async {
    final response = await _dataSource.getStepsWithReminders();
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al obtener pasos con recordatorios');
    }
  }

  /// Obtiene pasos vencidos
  Future<List<TreatmentStepResponse>> getOverdueSteps() async {
    final response = await _dataSource.getOverdueSteps();
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al obtener pasos vencidos');
    }
  }

  /// Obtiene tratamientos por ID de perfil
  Future<List<TreatmentResponse>> getTreatmentsByProfileId(int profileId) async {
    final response = await _dataSource.getTreatmentsByProfileId(profileId);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al obtener tratamientos del perfil');
    }
  }

  /// Obtiene tratamientos vencidos
  Future<List<TreatmentResponse>> getOverdueTreatments() async {
    final response = await _dataSource.getOverdueTreatments();
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al obtener tratamientos vencidos');
    }
  }

  /// Obtiene tratamientos por ID de cultivo
  Future<List<TreatmentResponse>> getTreatmentsByCropId(int cropId) async {
    final response = await _dataSource.getTreatmentsByCropId(cropId);
    if (response.success && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.error ?? 'Error al obtener tratamientos del cultivo');
    }
  }
} 