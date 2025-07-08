import 'package:ayni/core/constants/api_constants.dart';
import 'package:ayni/core/network/network_client.dart';
import 'package:ayni/plant/data/models/crop_model.dart';
import 'package:ayni/plant/data/models/diagnosis_model.dart';

class CropDataSource {

  final NetworkClient _networkClient;

  CropDataSource(this._networkClient);

  Future<ApiResponse<List<CropModel>>> fetchCrops(int profileId) async {
    return await _networkClient.request<List<CropModel>>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.crops}?profileId=$profileId',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      requiresAuth: true,
    );
  }

  Future<ApiResponse<CropModel>> getCropById(int cropId) async {
    return await _networkClient.request<CropModel>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.crops}/$cropId',
      method: RequestMethod.get,
      fromJson: (json) => CropModel.fromJson(json),
      requiresAuth: true,
    );
  }

  Future<ApiResponse<CropModel>> createCrop(Map<String, dynamic> cropData) async {
    return await _networkClient.request<CropModel>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.crops}',
      method: RequestMethod.post,
      data: cropData,
      fromJson: (json) => CropModel.fromJson(json),
      requiresAuth: true,
    );
  }

  Future<ApiResponse<CropModel>> updateCropStatus(int cropId, Map<String, dynamic> statusData) async {
    return await _networkClient.request<CropModel>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.crops}/$cropId/status',
      method: RequestMethod.put,
      data: statusData,
      fromJson: (json) => CropModel.fromJson(json),
      requiresAuth: true,
    );
  }

  Future<ApiResponse<List<CropModel>>> getCropsWithActiveDisease(int profileId) async {
    return await _networkClient.request<List<CropModel>>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.crops}/diseased?profileId=$profileId',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => CropModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      requiresAuth: true,
    );
  }

  // Métodos para diagnósticos
  Future<ApiResponse<List<DiagnosisModel>>> getDiagnosesByCropId(int cropId) async {
    return await _networkClient.request<List<DiagnosisModel>>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.diagnosis}?cropId=$cropId',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => DiagnosisModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      requiresAuth: true,
    );
  }

  Future<ApiResponse<DiagnosisModel>> startDiagnosis(Map<String, dynamic> diagnosisData) async {
    return await _networkClient.request<DiagnosisModel>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.diagnosis}',
      method: RequestMethod.post,
      data: diagnosisData,
      fromJson: (json) => DiagnosisModel.fromJson(json),
      requiresAuth: true,
    );
  }

  Future<ApiResponse<DiagnosisModel>> getDiagnosisById(int diagnosisId) async {
    return await _networkClient.request<DiagnosisModel>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.diagnosis}/$diagnosisId',
      method: RequestMethod.get,
      fromJson: (json) => DiagnosisModel.fromJson(json),
      requiresAuth: true,
    );
  }

  Future<ApiResponse<List<DiagnosisModel>>> getDiagnosesByProfileId(int profileId) async {
    return await _networkClient.request<List<DiagnosisModel>>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.diagnosis}/profile/$profileId',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => DiagnosisModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      requiresAuth: true,
    );
  }

  Future<ApiResponse<List<DiagnosisModel>>> getPendingDiagnoses() async {
    return await _networkClient.request<List<DiagnosisModel>>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.diagnosis}/pending',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((e) => DiagnosisModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
      requiresAuth: true,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getDetectionServiceStatus() async {
    return await _networkClient.request<Map<String, dynamic>>(
      endpoint: '${ApiConstants.cropServiceBaseUrl}${ApiConstants.diagnosis}/detection-service/status',
      method: RequestMethod.get,
      fromJson: (json) => json as Map<String, dynamic>,
      requiresAuth: true,
    );
  }
}