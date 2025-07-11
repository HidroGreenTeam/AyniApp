import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/network_client.dart';
import '../models/detection_api_models.dart';

/// Data source para el microservicio de detección de enfermedades de plantas
class DetectionApiDataSource {
  final NetworkClient _networkClient;

  DetectionApiDataSource(this._networkClient);

  /// Predice enfermedad en una imagen sin guardar en base de datos
  /// POST /api/v1/detections/predict
  Future<ApiResponse<PredictionResponse>> predictDisease(File imageFile) async {
    final url = Uri.parse('${ApiConstants.detectionServiceBaseUrl}${ApiConstants.detectionServicePredict}');
    
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['accept'] = 'application/json';
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse<PredictionResponse>(
          data: PredictionResponse.fromJson(jsonData),
          success: true,
        );
      } else {
        return ApiResponse<PredictionResponse>(
          error: 'Error en predicción: ${response.statusCode}',
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<PredictionResponse>(
        error: 'Error de red en predicción: $e',
        success: false,
      );
    }
  }

  /// Realiza diagnóstico completo, guarda imagen en Cloudinary y almacena en base de datos
  /// POST /api/v1/detections/diagnose
  Future<ApiResponse<DiagnosisApiResponse>> createDiagnosis({
    required File imageFile,
    int? cropId,
    int? profileId,
  }) async {
    // Construir URL con query parameters
    var uri = Uri.parse('${ApiConstants.detectionServiceBaseUrl}${ApiConstants.detectionServiceDiagnose}');
    final queryParams = <String, String>{};
    
    if (cropId != null) {
      queryParams['crop_id'] = cropId.toString();
    }
    if (profileId != null) {
      queryParams['profile_id'] = profileId.toString();
    }
    
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    
    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers['accept'] = 'application/json';
      
      // Agregar token de autenticación si está disponible
      // Nota: Esto debería ser manejado por NetworkClient, pero para multipart necesitamos hacerlo manualmente
      // TODO: Integrar mejor con NetworkClient para autenticación automática
      
      // Determinar tipo MIME y agregar archivo
      String? mimeType = lookupMimeType(imageFile.path);
      
      // Si no se puede determinar, forzar JPEG
      if (mimeType == null || !mimeType.startsWith('image/')) {
        mimeType = 'image/jpeg';
      }
      
      // Debug info (remover en producción)
      // print('Sending file: ${imageFile.path}');
      // print('MIME type detected: $mimeType');
      // print('File size: ${await imageFile.length()} bytes');
      
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        await imageFile.readAsBytes(),
        filename: 'image.jpg',
        contentType: MediaType.parse(mimeType),
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse<DiagnosisApiResponse>(
          data: DiagnosisApiResponse.fromJson(jsonData),
          success: true,
        );
      } else {
        return ApiResponse<DiagnosisApiResponse>(
          error: 'Error en diagnóstico: ${response.statusCode} - ${response.body}',
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<DiagnosisApiResponse>(
        error: 'Error de red en diagnóstico: $e',
        success: false,
      );
    }
  }

  /// Obtiene un diagnóstico específico por ID
  /// GET /api/v1/detections/detail/{diagnosisId}
  Future<ApiResponse<DiagnosisApiResponse>> getDiagnosisById(int diagnosisId) async {
    return await _networkClient.request<DiagnosisApiResponse>(
      endpoint: '${ApiConstants.detectionServiceBaseUrl}${ApiConstants.detectionServiceDetail}/$diagnosisId',
      method: RequestMethod.get,
      fromJson: (json) => DiagnosisApiResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: false,
    );
  }

  /// Obtiene todos los diagnósticos de un crop específico
  /// GET /api/v1/detections/crop/{cropId}
  Future<ApiResponse<List<DiagnosisApiResponse>>> getDiagnosesByCrop(int cropId) async {
    return await _networkClient.request<List<DiagnosisApiResponse>>(
      endpoint: '${ApiConstants.detectionServiceBaseUrl}${ApiConstants.detectionServiceByCrop}/$cropId',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => DiagnosisApiResponse.fromJson(e as Map<String, dynamic>)).toList();
        } else if (json is Map<String, dynamic> && json['diagnoses'] != null) {
          final diagnoses = json['diagnoses'] as List;
          return diagnoses.map((e) => DiagnosisApiResponse.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <DiagnosisApiResponse>[];
      },
      requiresAuth: false,
    );
  }

  /// Obtiene el historial de diagnósticos de un farmer/profile
  /// GET /api/v1/detections/{farmerId}
  Future<ApiResponse<List<DiagnosisApiResponse>>> getFarmerDiagnosisHistory(int farmerId) async {
    return await _networkClient.request<List<DiagnosisApiResponse>>(
      endpoint: '${ApiConstants.detectionServiceBaseUrl}${ApiConstants.detectionServiceByFarmer}/$farmerId',
      method: RequestMethod.get,
      fromJson: (json) {
        if (json is List) {
          return json.map((e) => DiagnosisApiResponse.fromJson(e as Map<String, dynamic>)).toList();
        } else if (json is Map<String, dynamic> && json['diagnoses'] != null) {
          final diagnoses = json['diagnoses'] as List;
          return diagnoses.map((e) => DiagnosisApiResponse.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <DiagnosisApiResponse>[];
      },
      requiresAuth: false,
    );
  }

  /// Obtiene estadísticas del servicio de detección
  /// GET /api/v1/detections/statistics
  Future<ApiResponse<DetectionStatisticsResponse>> getStatistics() async {
    return await _networkClient.request<DetectionStatisticsResponse>(
      endpoint: '${ApiConstants.detectionServiceBaseUrl}${ApiConstants.detectionServiceStatistics}',
      method: RequestMethod.get,
      fromJson: (json) => DetectionStatisticsResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: false,
    );
  }

  /// Health check del servicio
  /// GET /api/v1/detections/health/api/v1/health
  Future<ApiResponse<HealthCheckResponse>> healthCheck() async {
    return await _networkClient.request<HealthCheckResponse>(
      endpoint: '${ApiConstants.detectionServiceBaseUrl}${ApiConstants.detectionServiceHealth}',
      method: RequestMethod.get,
      fromJson: (json) => HealthCheckResponse.fromJson(json as Map<String, dynamic>),
      requiresAuth: false,
    );
  }
} 