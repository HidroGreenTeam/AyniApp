import '../../../core/constants/api_constants.dart';
import '../../../core/network/network_client.dart';
import '../models/treatment_models.dart';

/// Data source para el microservicio de tratamientos HidroBots
class TreatmentDataSource {
  final NetworkClient _networkClient;

  TreatmentDataSource(this._networkClient);

  /// Actualiza un paso de tratamiento
  /// PUT /api/v1/treatments/steps/{stepId}
  Future<ApiResponse<TreatmentStepResponse>> updateStep(
    int stepId,
    CreateTreatmentStepRequest request,
  ) async {
    return await _networkClient.request<TreatmentStepResponse>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentSteps}/$stepId',
      method: RequestMethod.put,
      data: request.toJson(),
      fromJson: (json) => TreatmentStepResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );
  }

  /// Obtiene pasos de tratamiento por ID de tratamiento
  /// GET /api/v1/treatments/{treatmentId}/steps
  Future<ApiResponse<List<TreatmentStepResponse>>> getStepsByTreatmentId(int treatmentId) async {
    return await _networkClient.request<List<TreatmentStepResponse>>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentsByTreatmentId}/$treatmentId/steps',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => TreatmentStepResponse.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <TreatmentStepResponse>[];
      },
      requiresAuth: true,
    );
  }

  /// Crea un nuevo paso de tratamiento
  /// POST /api/v1/treatments/{treatmentId}/steps
  Future<ApiResponse<TreatmentStepResponse>> createStep(
    int treatmentId,
    CreateTreatmentStepRequest request,
  ) async {
    return await _networkClient.request<TreatmentStepResponse>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentsByTreatmentId}/$treatmentId/steps',
      method: RequestMethod.post,
      data: request.toJson(),
      fromJson: (json) => TreatmentStepResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );
  }

  /// Marca un paso como omitido
  /// PATCH /api/v1/treatments/steps/{stepId}/skip
  Future<ApiResponse<TreatmentStepResponse>> skipStep(int stepId) async {
    return await _networkClient.request<TreatmentStepResponse>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentStepSkip}/$stepId/skip',
      method: RequestMethod.put,
      fromJson: (json) => TreatmentStepResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );
  }

  /// Marca un paso como completado
  /// PATCH /api/v1/treatments/steps/{stepId}/complete
  Future<ApiResponse<TreatmentStepResponse>> completeStep(int stepId) async {
    return await _networkClient.request<TreatmentStepResponse>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentStepComplete}/$stepId/complete',
      method: RequestMethod.put,
      fromJson: (json) => TreatmentStepResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );
  }

  /// Obtiene un tratamiento por ID
  /// GET /api/v1/treatments/{treatmentId}
  Future<ApiResponse<TreatmentResponse>> getTreatmentById(int treatmentId) async {
    return await _networkClient.request<TreatmentResponse>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentById}/$treatmentId',
      method: RequestMethod.get,
      fromJson: (json) => TreatmentResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: true,
    );
  }

  /// Obtiene pasos con recordatorios
  /// GET /api/v1/treatments/steps/reminders
  Future<ApiResponse<List<TreatmentStepResponse>>> getStepsWithReminders() async {
    return await _networkClient.request<List<TreatmentStepResponse>>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentStepsWithReminders}',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => TreatmentStepResponse.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <TreatmentStepResponse>[];
      },
      requiresAuth: true,
    );
  }

  /// Obtiene pasos vencidos
  /// GET /api/v1/treatments/steps/overdue
  Future<ApiResponse<List<TreatmentStepResponse>>> getOverdueSteps() async {
    return await _networkClient.request<List<TreatmentStepResponse>>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentOverdueSteps}',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => TreatmentStepResponse.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <TreatmentStepResponse>[];
      },
      requiresAuth: true,
    );
  }

  /// Obtiene tratamientos por ID de perfil
  /// GET /api/v1/treatments/profile/{profileId}
  Future<ApiResponse<List<TreatmentResponse>>> getTreatmentsByProfileId(int profileId) async {
    return await _networkClient.request<List<TreatmentResponse>>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentsByProfile}/$profileId',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => TreatmentResponse.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <TreatmentResponse>[];
      },
      requiresAuth: true,
    );
  }

  /// Obtiene tratamientos vencidos
  /// GET /api/v1/treatments/overdue
  Future<ApiResponse<List<TreatmentResponse>>> getOverdueTreatments() async {
    return await _networkClient.request<List<TreatmentResponse>>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentOverdue}',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => TreatmentResponse.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <TreatmentResponse>[];
      },
      requiresAuth: true,
    );
  }

  /// Obtiene tratamientos por ID de cultivo
  /// GET /api/v1/treatments/crop/{cropId}
  Future<ApiResponse<List<TreatmentResponse>>> getTreatmentsByCropId(int cropId) async {
    return await _networkClient.request<List<TreatmentResponse>>(
      endpoint: '${ApiConstants.treatmentServiceBaseUrl}${ApiConstants.treatmentsByCrop}/$cropId',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => TreatmentResponse.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <TreatmentResponse>[];
      },
      requiresAuth: true,
    );
  }
} 