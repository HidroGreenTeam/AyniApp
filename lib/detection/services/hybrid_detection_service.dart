import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/di/service_locator.dart';
import 'plant_disease_classifier.dart';
import '../data/datasources/detection_api_data_source.dart';
import '../data/models/detection_api_models.dart';

class DetectionResult {
  final String disease;
  final double confidence;
  final String formattedDiseaseName;
  final String recommendation;
  final bool isOnlineDetection;
  final String? warningMessage;
  final bool diseaseDetected;
  final bool requiresTreatment;

  DetectionResult({
    required this.disease,
    required this.confidence,
    required this.formattedDiseaseName,
    required this.recommendation,
    required this.isOnlineDetection,
    this.warningMessage,
    required this.diseaseDetected,
    required this.requiresTreatment,
  });
}

class HybridDetectionService {
  final PlantDiseaseClassifier _localClassifier = PlantDiseaseClassifier();
  final ConnectivityService _connectivityService = ConnectivityService();
  late final DetectionApiDataSource _detectionApiDataSource;

  HybridDetectionService() {
    _detectionApiDataSource = serviceLocator<DetectionApiDataSource>();
  }

  /// Initialize the detection service
  Future<bool> initialize() async {
    try {
      // Initialize local classifier
      final localInitSuccess = await _localClassifier.initialize();
      if (!localInitSuccess) {
        debugPrint('Warning: Local classifier initialization failed');
      }
      return true;
    } catch (e) {
      debugPrint('Error initializing hybrid detection service: $e');
      return false;
    }
  }

  /// Detect plant disease using the best available method
  Future<DetectionResult?> detectDisease(File imageFile) async {
    try {
      // Check connectivity first
      final hasInternet = await _connectivityService.hasInternetConnection();
      
      if (hasInternet) {
        // Try online detection first
        final onlineResult = await _detectOnline(imageFile);
        if (onlineResult != null) {
          return onlineResult;
        }
        
        // If online fails, fallback to local
        debugPrint('Online detection failed, falling back to local detection');
      }
      
      // Use local detection (either no internet or online failed)
      return await _detectLocal(imageFile);
      
    } catch (e) {
      debugPrint('Error in hybrid detection: $e');
      return null;
    }
  }

  /// Create a complete diagnosis using the microservice
  Future<DiagnosisApiResponse?> createDiagnosis({
    required File imageFile,
    int? cropId,
    int? profileId,
  }) async {
    try {
      final hasInternet = await _connectivityService.hasInternetConnection();
      
      if (!hasInternet) {
        throw Exception('Conexión a internet requerida para crear diagnóstico completo');
      }

      final response = await _detectionApiDataSource.createDiagnosis(
        imageFile: imageFile,
        cropId: cropId,
        profileId: profileId,
      );

      if (response.success && response.data != null) {
        return response.data;
      } else {
        throw Exception(response.error ?? 'Error al crear diagnóstico');
      }
    } catch (e) {
      debugPrint('Error creating diagnosis: $e');
      rethrow;
    }
  }

  /// Get diagnosis by ID
  Future<DiagnosisApiResponse?> getDiagnosisById(int diagnosisId) async {
    try {
      final response = await _detectionApiDataSource.getDiagnosisById(diagnosisId);
      
      if (response.success && response.data != null) {
        return response.data;
      } else {
        throw Exception(response.error ?? 'Error al obtener diagnóstico');
      }
    } catch (e) {
      debugPrint('Error getting diagnosis by ID: $e');
      return null;
    }
  }

  /// Get diagnoses by crop ID
  Future<List<DiagnosisApiResponse>> getDiagnosesByCrop(int cropId) async {
    try {
      final response = await _detectionApiDataSource.getDiagnosesByCrop(cropId);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.error ?? 'Error al obtener diagnósticos del cultivo');
      }
    } catch (e) {
      debugPrint('Error getting diagnoses by crop: $e');
      return [];
    }
  }

  /// Get farmer diagnosis history
  Future<List<DiagnosisApiResponse>> getFarmerDiagnosisHistory(int farmerId) async {
    try {
      final response = await _detectionApiDataSource.getFarmerDiagnosisHistory(farmerId);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        throw Exception(response.error ?? 'Error al obtener historial de diagnósticos');
      }
    } catch (e) {
      debugPrint('Error getting farmer diagnosis history: $e');
      return [];
    }
  }

  /// Get detection statistics
  Future<DetectionStatisticsResponse?> getStatistics() async {
    try {
      final response = await _detectionApiDataSource.getStatistics();
      
      if (response.success && response.data != null) {
        return response.data;
      } else {
        throw Exception(response.error ?? 'Error al obtener estadísticas');
      }
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return null;
    }
  }

  /// Health check
  Future<HealthCheckResponse?> healthCheck() async {
    try {
      final response = await _detectionApiDataSource.healthCheck();
      
      if (response.success && response.data != null) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error in health check: $e');
      return null;
    }
  }

  /// Detect using online model
  Future<DetectionResult?> _detectOnline(File imageFile) async {
    try {
      final response = await _detectionApiDataSource.predictDisease(imageFile);
      
      if (response.success && response.data != null) {
        final prediction = response.data!;
        
        return DetectionResult(
          disease: prediction.predictedClass,
          confidence: prediction.confidence,
          formattedDiseaseName: _formatDiseaseName(prediction.predictedClass),
          recommendation: _getRecommendationForDisease(
            prediction.predictedClass, 
            prediction.requiresTreatment
          ),
          isOnlineDetection: true,
          diseaseDetected: prediction.diseaseDetected,
          requiresTreatment: prediction.requiresTreatment,
        );
      } else {
        debugPrint('Online detection failed: ${response.error}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in online detection: $e');
      return null;
    }
  }

  /// Detect using local model
  Future<DetectionResult?> _detectLocal(File imageFile) async {
    try {
      final result = await _localClassifier.classifyImage(imageFile);
      
      if (result != null) {
        return DetectionResult(
          disease: result.disease,
          confidence: result.confidence,
          formattedDiseaseName: result.formattedDiseaseName,
          recommendation: result.recommendation,
          isOnlineDetection: false,
          warningMessage: 'Modelo local usado - menor precisión',
          diseaseDetected: result.disease != 'nodisease',
          requiresTreatment: result.disease != 'nodisease' && result.disease != 'unknown',
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Error in local detection: $e');
      return null;
    }
  }

  /// Force local detection (for offline mode)
  Future<DetectionResult?> detectLocalOnly(File imageFile) async {
    try {
      final result = await _localClassifier.classifyImage(imageFile);
      
      if (result != null) {
        return DetectionResult(
          disease: result.disease,
          confidence: result.confidence,
          formattedDiseaseName: result.formattedDiseaseName,
          recommendation: result.recommendation,
          isOnlineDetection: false,
          warningMessage: 'Modo offline - modelo local',
          diseaseDetected: result.disease != 'nodisease',
          requiresTreatment: result.disease != 'nodisease' && result.disease != 'unknown',
        );
      }
      
      return null;
    } catch (e) {
      debugPrint('Error in local-only detection: $e');
      return null;
    }
  }

  /// Force online detection (for testing or when user prefers online)
  Future<DetectionResult?> detectOnlineOnly(File imageFile) async {
    final hasInternet = await _connectivityService.hasInternetConnection();
    
    if (!hasInternet) {
      throw Exception('No internet connection available for online detection');
    }
    
    return await _detectOnline(imageFile);
  }

  /// Check if online detection is available
  Future<bool> isOnlineDetectionAvailable() async {
    return await _connectivityService.hasInternetConnection();
  }

  /// Check if local detection is available
  Future<bool> isLocalDetectionAvailable() async {
    try {
      return await _localClassifier.initialize();
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  String _formatDiseaseName(String diseaseName) {
    if (diseaseName == 'nodisease') {
      return 'Sin Enfermedad';
    } else if (diseaseName == 'unknown') {
      return 'Desconocido';
    }
    
    return diseaseName.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _getRecommendationForDisease(String disease, [bool requiresTreatment = false]) {
    switch (disease.toLowerCase()) {
      case 'nodisease':
        return 'Tu planta parece estar saludable! Continúa con tu rutina de cuidado actual.';
      case 'leaf_miner':
      case 'miner':
        if (requiresTreatment) {
          return 'Minador de hojas detectado. Se requiere tratamiento: remueve las hojas afectadas y aplica insecticida apropiado.';
        }
        return 'Minador de hojas detectado. Considera remover las hojas afectadas y aplicar insecticida apropiado.';
      case 'phoma_leaf_spot':
      case 'phoma':
        if (requiresTreatment) {
          return 'Mancha foliar por Phoma detectada. Se requiere tratamiento: evita el riego por aspersión y aplica fungicida apropiado.';
        }
        return 'Mancha foliar por Phoma detectada. Evita el riego por aspersión y aplica fungicida apropiado.';
      case 'red_spider_mite':
      case 'redspider':
        if (requiresTreatment) {
          return 'Ácaros rojos detectados. Se requiere tratamiento: aumenta la humedad y considera aplicar jabón insecticida.';
        }
        return 'Ácaros rojos detectados. Aumenta la humedad y considera aplicar jabón insecticida.';
      case 'leaf_rust':
      case 'rust':
        if (requiresTreatment) {
          return 'Roya foliar detectada. Se requiere tratamiento: remueve las partes afectadas y aplica fungicida a base de cobre.';
        }
        return 'Roya foliar detectada. Remueve las partes afectadas y aplica fungicida a base de cobre.';
      case 'unknown':
        return 'No se pudo identificar la condición de la planta. Intenta tomar una foto más clara con mejor iluminación.';
      default:
        if (requiresTreatment) {
          return 'Se requiere tratamiento. Consulta con un especialista en plantas para opciones de tratamiento apropiadas.';
        }
        return 'Consulta con un especialista en plantas para opciones de tratamiento apropiadas.';
    }
  }

  void dispose() {
    _localClassifier.dispose();
  }
} 